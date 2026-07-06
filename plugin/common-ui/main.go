package main

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

type UIPlugin struct {
	mux *http.ServeMux
}

func New() *UIPlugin {
	p := &UIPlugin{
		mux: http.NewServeMux(),
	}

	NewUIHandler().Register(p.mux)

	return p
}

func (p *UIPlugin) ServeHTTP(req shared.HTTPRequest) (shared.HTTPResponse, error) {
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

func (p *UIPlugin) GetRoutes() ([]string, error) {
	return []string{
		"/overview",
		"/students",
		"/staff",
		"/schools",
		"/sections",
	}, nil
}

func (p *UIPlugin) GetMenuItems() ([]shared.MenuItem, error) {
	return []shared.MenuItem{
		{Label: "Overview", Path: "/overview", AllowedRoles: []string{"admin", "teacher", "student", "guardian"}},
		{Label: "Students", Path: "/students", AllowedRoles: []string{"admin", "teacher"}},
		{Label: "Staff", Path: "/staff", AllowedRoles: []string{"admin", "teacher"}},
		{Label: "Schools", Path: "/schools", AllowedRoles: []string{"admin"}},
		{Label: "Course Sections", Path: "/sections", AllowedRoles: []string{"admin", "teacher"}},
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
