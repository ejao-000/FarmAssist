package httputil

import (
	"encoding/json"
	"net/http"
)

func jsonResponse(w http.ResponseWriter, v any) error {
	return json.NewEncoder(w).Encode(v)
}

func JSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = jsonResponse(w, v)
}
