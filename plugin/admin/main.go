package main

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"os"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

type AdminPlugin struct {
	mux *http.ServeMux
}

func New() *AdminPlugin {
	p := &AdminPlugin{
		mux: http.NewServeMux(),
	}

	prefix := os.Getenv("OASIS_PLUGIN_PREFIX")
	if prefix == "" {
		prefix = "api/admin"
	}
	basePath := "/" + prefix

	p.mux.HandleFunc("GET " + basePath + "/health", p.handleHealth)
	p.mux.HandleFunc("GET " + basePath + "/settings", p.handleSettings)

	return p
}

func (p *AdminPlugin) handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
		"version": "1.0.0",
		"uptime": "99.9%",
	})
}

func (p *AdminPlugin) handleSettings(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"maintenance_mode": false,
		"max_users": 5000,
		"features": []string{"grades", "attendance", "discipline"},
	})
}

func (p *AdminPlugin) ServeHTTP(req shared.HTTPRequest) (shared.HTTPResponse, error) {
	r, err := http.NewRequest(req.Method, req.URL, bytes.NewReader(req.Body))
	if err != nil {
		return shared.HTTPResponse{}, err
	}
	r.Header = req.Header

	w := httptest.NewRecorder()
	p.mux.ServeHTTP(w, r)

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

func (p *AdminPlugin) GetRoutes() ([]string, error) {
	return []string{}, nil
}

func (p *AdminPlugin) GetMenuItems() ([]shared.MenuItem, error) {
	return nil, nil
}

func main() {
	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins: map[string]plugin.Plugin{
			"http_plugin": &shared.HTTPPluginAdapter{Impl: New()},
		},
	})
}
