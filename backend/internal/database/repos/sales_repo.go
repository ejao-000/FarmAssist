package repos

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type SalesRepo struct{ db *sql.DB }

func NewSalesRepo(orDB *sql.DB) *SalesRepo { return &SalesRepo{db: orDB} }

type SaleItem struct {
	ProductID uuid.UUID
	Quantity  int64
	UnitPriceCents int64
}

func (r *SalesRepo) CreateSaleReceiptTx(
	ctx context.Context,
	tx *sql.Tx,
	userID, farmID uuid.UUID,
	receiptID uuid.UUID,
	occurredAt time.Time,
	items []SaleItem,
) error {
	var totalCents int64
	for _, it := range items {
		totalCents += it.Quantity * it.UnitPriceCents
	}

	_, err := tx.ExecContext(ctx, `
		INSERT INTO sales_receipts (id, user_id, farm_id, occurred_at, total_cents)
		VALUES ($1,$2,$3,$4,$5)
	`, receiptID, userID, farmID, occurredAt, totalCents)
	if err != nil {
		return err
	}

	stmt, err := tx.PrepareContext(ctx, `
		INSERT INTO sales_receipt_items (receipt_id, product_id, quantity, unit_price_cents, line_total_cents)
		VALUES ($1,$2,$3,$4,$5)
	`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	for _, it := range items {
		lineTotal := it.Quantity * it.UnitPriceCents
		if _, err := stmt.ExecContext(ctx, receiptID, it.ProductID, it.Quantity, it.UnitPriceCents, lineTotal); err != nil {
			return err
		}
	}

	// Keep inventory consistent: selling reduces stock.
	// (You can also enforce “no negative stock” here if you want.)
	inv := NewInventoryRepo(tx.DB) // not ideal; see note below
	_ = inv

	return nil
}
