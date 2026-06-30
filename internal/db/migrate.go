package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Migrate runs all pending SQL migration files from the given directory.
// Migrations are tracked in a _migrations table and applied in filename order.
// Each migration file must have a .sql extension and should be named with a
// numeric prefix for ordering (e.g., 001_core.sql, 002_k12.sql).
func Migrate(db *sql.DB, migrationsDir string) error {
	// Create the migrations tracking table if it doesn't exist
	_, err := db.Exec(`CREATE TABLE IF NOT EXISTS _migrations (
		filename TEXT NOT NULL PRIMARY KEY,
		applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
	)`)
	if err != nil {
		return fmt.Errorf("failed to create _migrations table: %w", err)
	}

	// Get list of already-applied migrations
	applied := make(map[string]bool)
	rows, err := db.Query("SELECT filename FROM _migrations")
	if err != nil {
		return fmt.Errorf("failed to query _migrations: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var filename string
		if err := rows.Scan(&filename); err != nil {
			return fmt.Errorf("failed to scan migration row: %w", err)
		}
		applied[filename] = true
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("error iterating migration rows: %w", err)
	}

	// Read migration files from directory
	entries, err := os.ReadDir(migrationsDir)
	if err != nil {
		if os.IsNotExist(err) {
			log.Println("No migrations directory found, skipping migrations")
			return nil
		}
		return fmt.Errorf("failed to read migrations directory: %w", err)
	}

	// Filter and sort SQL files
	var files []string
	for _, entry := range entries {
		if !entry.IsDir() && strings.HasSuffix(entry.Name(), ".sql") {
			files = append(files, entry.Name())
		}
	}
	sort.Strings(files)

	// Apply pending migrations
	for _, filename := range files {
		if applied[filename] {
			continue
		}

		log.Printf("Applying migration: %s", filename)

		content, err := os.ReadFile(filepath.Join(migrationsDir, filename))
		if err != nil {
			return fmt.Errorf("failed to read migration %s: %w", filename, err)
		}

		tx, err := db.Begin()
		if err != nil {
			return fmt.Errorf("failed to begin transaction for %s: %w", filename, err)
		}

		if _, err := tx.Exec(string(content)); err != nil {
			tx.Rollback()
			return fmt.Errorf("failed to apply migration %s: %w", filename, err)
		}

		if _, err := tx.Exec("INSERT INTO _migrations (filename) VALUES (?)", filename); err != nil {
			tx.Rollback()
			return fmt.Errorf("failed to record migration %s: %w", filename, err)
		}

		if err := tx.Commit(); err != nil {
			return fmt.Errorf("failed to commit migration %s: %w", filename, err)
		}

		log.Printf("Applied migration: %s", filename)
	}

	return nil
}
