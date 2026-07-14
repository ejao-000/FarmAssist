package httputil

import "net/http"

type APIError struct {
	Status int    `json:"status"`
	Code   string `json:"code"`
	Error  string `json:"error"`
}

func Write(w http.ResponseWriter, status int, code, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = jsonResponse(w, APIError{
		Status: status,
		Code:   code,
		Error:  msg,
	})
}
