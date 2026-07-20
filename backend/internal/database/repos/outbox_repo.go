package repos

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

type OutboxRepo struct {
	db *sql.DB
}

func NewOutboxRepo(tx orDB *sql.DB) *OutboxRepo {
	return &OutboxRepo{db: orDB}
}

// MutationEvent is what mobile sends to /sync/changes (bulk).
// Store the raw payload + type; compute conflicts server-side.
type MutationEvent struct {
	ID          uuid.UUID
	UserID      uuid.UUID
	DeviceID    string
	EntityType  string // "inventory_movement", "disease_upload", etc
	EntityID    string // optional; keep stable string keys if you have them
	OccurredAt  time.Time
	IdempotKey  string // usually == client mutation UUID
	PayloadJSON json.RawMessage
}

func (r *OutboxRepo) InsertMutation(ctx context.Context, ev MutationEvent) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO sync_outbox
			(id, user_id, device_id, entity_type, entity_id, occurred_at, idempot_key, payload_json, status)
		VALUES
			($1,$2,$3,$4,$5,$6,$7,$8,'queued')
		ON CONFLICT (idempot_key) DO NOTHING
	`, ev.ID, ev.UserID, ev.DeviceID, ev.EntityType, ev.EntityID, ev.OccurredAt, ev.IdempotKey, ev.PayloadJSON)
	return err
}
