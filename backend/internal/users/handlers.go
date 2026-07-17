package users

import (
	"context"
	"encoding/json"
	"net/http"

	"farmassist/backend/internal/database"
)

// UserDTO is the response shape required by the frontend.
type UserDTO struct {
	ID    int64  `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
	Role  string `json:"role"`
}

type Handler struct {
	DB *database.DB
}

func NewHandler(db *database.DB) *Handler {
	return &Handler{DB: db}
}

func (h *Handler) ListUsers(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Replace this query if your schema differs.
	const q = `
		SELECT id, name, email, role
		FROM users
		ORDER BY id DESC
	`

	rows, err := h.DB.QueryContext(ctx, q)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to query users")
		return
	}
	defer rows.Close()

	var users []UserDTO
	for rows.Next() {
		var u UserDTO
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.Role); err != nil {
			writeError(w, http.StatusInternalServerError, "failed to scan users")
			return
		}
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "row iteration error")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"users": users,
	})
}

// Small helpers (you can delete these if you already have httputil helpers)
func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]any{
		"error": message,
	})
}

// Compile-time check that we have the DB dependency you expect.
// Remove if your database.DB has a different name/type.
var _ context.Context
