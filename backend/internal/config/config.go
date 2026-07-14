package config

import (
	"os"
	"strconv"
)

type Config struct {
	Port         int
	DatabaseURL  string
}

func Load() Config {
	port := 8080
	if v := os.Getenv("PORT"); v != "" {
		if p, err := strconv.Atoi(v); err == nil {
			port = p
		}
	}

	return Config{
		Port:         port,
		DatabaseURL:  mustEnv("DATABASE_URL"),
	}
}

func mustEnv(k string) string {
	v := os.Getenv(k)
	if v == "" {
		panic("missing env: " + k)
	}
	return v
}
