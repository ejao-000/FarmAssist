package repos

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type SyncRepo struct {
	db *sql.DB
}

func NewSyncRepo(orDB *sql.DB) *SyncRepo {
	return &SyncRepo{db: orDB}
}

// Server cursor = monotonically increasing change id or LSN-like value.
type Cursor struct {
	UserID uuid.UUID
	DeviceID string
	LastApplied int64
	UpdatedAt time.Time
}

func (r *SyncRepo) GetCursor(ctx context.Context, userID uuid.UUID, deviceID string) (Cursor, error) {
	var c Cursor
	err := r.db.QueryRowContext(ctx, `
		SELECT user_id, device_id, last_applied, updated_at
		FROM sync_cursors
		WHERE user_id=$1 AND device_id=$2
	`, userID, deviceID).Scan(&c.UserID, &c.DeviceID, &c.LastApplied, &c.UpdatedAt)
	if err == sql.ErrNoRows {
		return c, nil // treat as cursor=0 elsewhere
	}
	return c, err
}

func (r *SyncRepo) BumpCursor(ctx context.Context, userID uuid.UUID, deviceID string, lastApplied int64) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO sync_cursors (user_id, device_id, last_applied, updated_at)
		VALUES ($1,$2,$3,now())
		ON CONFLICT (user_id, device_id) DO UPDATE SET last_applied=GREATEST(sync_cursors.last_applied, EXCLUDED.last_applied), updated_at=now()
	`, userID, deviceID, lastApplied)
	return err
}
