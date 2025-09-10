// file: plugins/academics/main.go
package main

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

// CommonPlugin implements the HTTPPlugin interface from the shared package.
type CommonPlugin struct {
	mux *http.ServeMux
}

// New creates and initializes our plugin, setting up its internal routes.
func New() *CommonPlugin {
	p := &CommonPlugin{
		mux: http.NewServeMux(),
	}
	p.mux.HandleFunc("/grades", p.gradesHandler)
	p.mux.HandleFunc("/attendance", p.attendanceHandler)
	return p
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
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"student_id": "123", "status": "Present"}`))
}

// main is the entry point that serves the plugin.
func main() {
	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins: map[string]plugin.Plugin{
			"http_plugin": &shared.HTTPPluginAdapter{Impl: New()},
		},
	})
}
