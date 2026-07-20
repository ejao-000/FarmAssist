package repos

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type DiseaseRepo struct{ db *sql.DB }

func NewDiseaseRepo(orDB *sql.DB) *DiseaseRepo { return &DiseaseRepo{db: orDB} }

type DiseaseUpload struct {
	ID uuid.UUID
	FarmID uuid.UUID
	UserID uuid.UUID
	ImageObjectKey string // where the image is stored (S3/local compatible)
	OccurredAt time.Time
	Status string // queued/processing/ready/failed
	ModelVersion string
	Confidence float64
	ResultLabel string
}

func (r *DiseaseRepo) CreateUploadTx(
	ctx context.Context,
	tx *sql.Tx,
	userID, farmID uuid.UUID,
	uploadID uuid.UUID,
	imageObjectKey string,
	occurredAt time.Time,
) error {
	_, err := tx.ExecContext(ctx, `
		INSERT INTO disease_uploads (id, user_id, farm_id, image_object_key, occurred_at, status)
		VALUES ($1,$2,$3,$4,$5,'queued')
		ON CONFLICT (id) DO NOTHING
	`, uploadID, userID, farmID, imageObjectKey, occurredAt)
	return err
}

func (r *DiseaseRepo) SetStatus(ctx context.Context, uploadID uuid.UUID, status string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE disease_uploads SET status=$2 WHERE id=$1
	`, uploadID, status)
	return err
}

func (r *DiseaseRepo) SetResult(ctx context.Context, uploadID uuid.UUID, label string, confidence float64, modelVersion string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE disease_uploads
		SET status='ready', result_label=$2, confidence=$3, model_version=$4, completed_at=now()
		WHERE id=$1
	`, uploadID, label, confidence, modelVersion)
	return err
}

func (r *DiseaseRepo) GetByID(ctx context.Context, uploadID, userID uuid.UUID) (DiseaseUpload, error) {
	var u DiseaseUpload
	err := r.db.QueryRowContext(ctx, `
		SELECT id, farm_id, user_id, image_object_key, occurred_at, status, model_version, confidence, result_label
		FROM disease_uploads WHERE id=$1 AND user_id=$2
	`, uploadID, userID).Scan(&u.ID, &u.FarmID, &u.UserID, &u.ImageObjectKey, &u.OccurredAt, &u.Status, &u.ModelVersion, &u.Confidence, &u.ResultLabel)
	if err == sql.ErrNoRows {
		return u, data.ErrNotFound
	}
	return u, err
}
