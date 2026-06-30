package db

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
)

// Config holds database configuration loaded from plugins.yaml.
type Config struct {
	URL             string `yaml:"url"`
	MaxOpenConns    int    `yaml:"max_open_conns"`
	MaxIdleConns    int    `yaml:"max_idle_conns"`
	ConnMaxLifetime string `yaml:"conn_max_lifetime"`
}

// Open initializes a Postgres database connection with the given config.
// This is used by the host process for running migrations and managing
// the database lifecycle.
func Open(cfg Config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.URL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database at %s: %w", cfg.URL, err)
	}

	// Connection pool
	db.SetMaxOpenConns(cfg.MaxOpenConns)
	db.SetMaxIdleConns(cfg.MaxIdleConns)
	if cfg.ConnMaxLifetime != "" {
		d, err := time.ParseDuration(cfg.ConnMaxLifetime)
		if err != nil {
			db.Close()
			return nil, fmt.Errorf("invalid conn_max_lifetime %q: %w", cfg.ConnMaxLifetime, err)
		}
		db.SetConnMaxLifetime(d)
	}

	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}
