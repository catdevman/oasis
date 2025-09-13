package main

import (
	"bytes"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	_ "net/http/pprof"
	"strings"
	"sync"
	"time"

	"database/sql"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
	_ "modernc.org/sqlite"
)

// CommonPlugin implements the HTTPPlugin interface from the shared package.
type CommonPlugin struct {
	mux    *http.ServeMux
	db     *sql.DB
	dbOnce sync.Once
}

// New creates and initializes our plugin, setting up its internal routes.
func New() *CommonPlugin {
	p := &CommonPlugin{
		mux: http.NewServeMux(),
	}
	p.dbOnce.Do(p.setupDatabase)
	p.mux.HandleFunc("/grades", p.gradesHandler)
	p.mux.HandleFunc("/attendance", p.attendanceHandler)
	return p
}

func (p *CommonPlugin) setupDatabase() {
	db, err := sql.Open("sqlite", "file:/home/developer/code/github.com/catdevman/oasis/oasis.db?cache=shared&_journal_mode=WAL&_busy_timeout=5000")
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}

	// Configure the connection pool.
	db.SetMaxOpenConns(25) // The default is 0 (unlimited)
	db.SetMaxIdleConns(25) // The default is 2
	db.SetConnMaxLifetime(5 * time.Minute)

	// Ping the database to ensure the connection is established.
	if err = db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	log.Println("Database connection pool established.")
	p.db = db
}

// ServeHTTP is the adapter that translates between the RPC structs and standard http types.
func (p *CommonPlugin) ServeHTTP(req shared.HTTPRequest) (shared.HTTPResponse, error) {
	// Reconstruct the request.
	r, err := http.NewRequest(req.Method, req.URL, bytes.NewReader(req.Body))
	if err != nil {
		return shared.HTTPResponse{}, err
	}
	r.Header = req.Header

	// Use a ResponseRecorder to capture the handler's output.
	w := httptest.NewRecorder()

	// Serve the request using the plugin's internal mux.
	p.mux.ServeHTTP(w, r)

	// Extract the recorder's response and convert it to our serializable struct.
	resp := w.Result()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return shared.HTTPResponse{}, err
	}

	return shared.HTTPResponse{
		StatusCode: resp.StatusCode,
		Header:     resp.Header,
		Body:       body,
	}, nil
}

// gradesHandler is a standard http.HandlerFunc.
func (p *CommonPlugin) gradesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"student_id": "123", "grade": "A"}`))
}

// attendanceHandler is another standard http.HandlerFunc.
func (p *CommonPlugin) attendanceHandler(w http.ResponseWriter, r *http.Request) {
	query := "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"

	rows, err := p.db.Query(query)
	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error_message": "database connection"}`))
		return
	}
	defer rows.Close()

	var names []string
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(`{"error_message": "database connection"}`))
			return
		}
		names = append(names, name)
	}

	// Check for errors from iterating over rows.
	if err := rows.Err(); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error_message": "database connection"}`))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"student_id": "123", "table_names": "` + strings.Join(names, ",") + `"}`))
}

// main is the entry point that serves the plugin.
func main() {
	go func() {
		log.Println("Starting pprof server on :6060")
		log.Println(http.ListenAndServe("localhost:6060", nil))
	}()

	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins: map[string]plugin.Plugin{
			"http_plugin": &shared.HTTPPluginAdapter{Impl: New()},
		},
	})
}
