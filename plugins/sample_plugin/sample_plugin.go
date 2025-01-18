package main

import (
	"context"
	"fmt"
	"net/http"

	"github.com/catdevman/oasis/plugins"
	"github.com/hashicorp/go-plugin"
)

// SamplePlugin is an example plugin that provides a route.
type SamplePlugin struct{}

// Routes returns the routes provided by the plugin.
func (p *SamplePlugin) Routes(ctx context.Context) (plugins.Route, error) {
	return plugins.Route{
		Name:        "sample_route",
		Method:      http.MethodGet,
		Pattern:     "/sample",
		HandlerFunc: p.handleSampleRoute,
	}, nil
}

func (p *SamplePlugin) handleSampleRoute(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello from sample plugin!")
}

func main() {
	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: plugin.HandshakeConfig{
			ProtocolVersion:  1,
			MagicCookieKey:   "PLUGIN_MAGIC_COOKIE",
			MagicCookieValue: "hello",
		},
		Plugins: map[string]plugin.Plugin{
			"sample_plugin": &RoutePluginImpl{Impl: &SamplePlugin{}},
		},
		// A non-nil value here enables gRPC serving for this plugin...
		GRPCServer: plugin.DefaultGRPCServer,
	})
}

// RoutePluginImpl is a wrapper for the RoutePlugin interface that allows us to
// use the plugin package's GRPC server.
type RoutePluginImpl struct {
	plugin.Plugin
	Impl plugins.RoutePlugin
}

func (p *RoutePluginImpl) GRPCServer(broker *plugin.GRPCBroker, s *plugin.GRPCServer) error {
	return nil
}

func (p *RoutePluginImpl) GRPCClient(ctx context.Context, broker *plugin.GRPCBroker, c *plugin.GRPCClient) (interface{}, error) {
	return nil, nil
}
