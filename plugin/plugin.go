package main

import (
	"net/http"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

func main() {
	// Register types for gob serialization.
	shared.RegisterTypes()

	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.HandshakeConfig,
		Plugins: map[string]plugin.Plugin{
			"routePlugin": &shared.ServeMuxPlugin{Impl: &PluginImpl{}},
		},
	})
}

// PluginImpl implements the RoutePlugin interface.
type PluginImpl struct{}

func (p *PluginImpl) GetRoutes() ([]shared.Route, error) {
	return []shared.Route{
		{
			Method:    "GET",
			Pattern:   "/hello",
			HandlerID: "helloHandler",
		},
	}, nil
}

var handlers = map[string]func(shared.SerializedRequest) shared.SerializedResponse{
	"helloHandler": func(req shared.SerializedRequest) shared.SerializedResponse {
		if req.Method != "GET" {
			return shared.SerializedResponse{
				StatusCode: http.StatusMethodNotAllowed,
				Body:       "Method not allowed",
			}
		}
		return shared.SerializedResponse{
			Header: map[string][]string{
				"Content-Type": {
					"application/json",
				},
			},
			StatusCode: http.StatusOK,
			Body:       `{"something": "here3"}`,
		}
	},
}

func (p *PluginImpl) HandleRequest(handlerID string, req shared.SerializedRequest) (shared.SerializedResponse, error) {
	handler, ok := handlers[handlerID]
	if !ok {
		return shared.SerializedResponse{
			StatusCode: http.StatusNotFound,
			Body:       "Handler not found",
		}, nil
	}

	return handler(req), nil
}

