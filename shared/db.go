package shared

import (
	"database/sql"
	"fmt"
	"os"
	"time"

	_ "github.com/lib/pq"
)

// OpenDatabase reads the OASIS_DB_URL environment variable and opens
// a Postgres connection with standardized settings. Plugins should call this
// instead of opening the database directly.
func OpenDatabase() (*sql.DB, error) {
	dbURL := os.Getenv("OASIS_DB_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("OASIS_DB_URL environment variable not set")
	}

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Connection pool settings
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}
