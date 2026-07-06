package main

import (
	"bytes"
	"embed"
	"encoding/json"
	"html/template"
	"io"
	"net/http"
	"net/http/httptest"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

//go:embed ui/*.html
var uiTemplates embed.FS

type AdminUIPlugin struct {
	mux  *http.ServeMux
	tmpl *template.Template
}

func New() *AdminUIPlugin {
	tmpl := template.Must(template.ParseFS(uiTemplates, "ui/*.html"))
	
	p := &AdminUIPlugin{
		mux:  http.NewServeMux(),
		tmpl: tmpl,
	}

	p.mux.HandleFunc("GET /settings", p.handleSettings)
	p.mux.HandleFunc("GET /system-health", p.handleHealth)

	return p
}

func fetchAPI(endpoint string, result interface{}) error {
	resp, err := http.Get("http://127.0.0.1:8080/api/admin/" + endpoint)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	
	return json.Unmarshal(body, result)
}

func (p *AdminUIPlugin) renderTemplate(w http.ResponseWriter, name string, data interface{}) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`<div class="content-card">` + "\n"))
	err := p.tmpl.ExecuteTemplate(w, name, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Write([]byte("\n" + `</div>`))
}

func (p *AdminUIPlugin) handleSettings(w http.ResponseWriter, r *http.Request) {
	var data map[string]interface{}
	err := fetchAPI("settings", &data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	p.renderTemplate(w, "settings.html", data)
}

func (p *AdminUIPlugin) handleHealth(w http.ResponseWriter, r *http.Request) {
	var data map[string]interface{}
	err := fetchAPI("health", &data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	p.renderTemplate(w, "health.html", data)
}

func (p *AdminUIPlugin) ServeHTTP(req shared.HTTPRequest) (shared.HTTPResponse, error) {
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

func (p *AdminUIPlugin) GetRoutes() ([]string, error) {
	return []string{
		"/settings",
		"/system-health",
	}, nil
}

func (p *AdminUIPlugin) GetMenuItems() ([]shared.MenuItem, error) {
	return []shared.MenuItem{
		{Label: "Settings", Path: "/settings", AllowedRoles: []string{"admin"}},
		{Label: "System Health", Path: "/system-health", AllowedRoles: []string{"admin"}},
	}, nil
}

func main() {
	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins: map[string]plugin.Plugin{
			"http_plugin": &shared.HTTPPluginAdapter{Impl: New()},
		},
	})
}
