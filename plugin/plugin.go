package main

import (
	"fmt"
	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
	"net/http"
)

type StaticRoutePlugin struct{}

// GetRoutes returns a static list of routes.
func (p StaticRoutePlugin) GetRoutes() ([]shared.Route, error) {
	return []shared.Route{
		{
			Method:  "GET",
			Pattern: "/hello",
			Handler: func(w http.ResponseWriter, r *http.Request) {
				if r.Method != "GET" {
					http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
					return
				}
				fmt.Fprintf(w, "Hello, world!")
			},
		},
		{
			Method:  "POST",
			Pattern: "/echo",
			Handler: func(w http.ResponseWriter, r *http.Request) {
				if r.Method != "POST" {
					http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
					return
				}
				body := make([]byte, r.ContentLength)
				r.Body.Read(body)
				fmt.Fprintf(w, "Received: %s", string(body))
			},
		},
	}, nil
}

func main() {
	plug := StaticRoutePlugin{}
	// pluginMap is the map of plugins we can dispense.
	var pluginMap = map[string]plugin.Plugin{
		"routePlugin": &shared.ServeMuxPlugin{Impl: plug},
	}

	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins:         pluginMap,
	})
}
