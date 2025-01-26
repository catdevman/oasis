package shared

import (
	"github.com/hashicorp/go-plugin"
	"net/rpc"
)

var Handshake = plugin.HandshakeConfig{
	ProtocolVersion:  1,
	MagicCookieKey:   "ROUTE_PLUGIN",
	MagicCookieValue: "dynamic-api",
}

// RoutePlugin interface defines a method for retrieving routes.
type RoutePlugin interface {
	GetRoutes() ([]Route, error)
}

// ServeMuxPlugin is the RPC server that plugins will use.
type ServeMuxPlugin struct {
	Impl RoutePlugin
}

func (p *ServeMuxPlugin) Server(*plugin.MuxBroker) (interface{}, error) {
	return &ServeMuxPluginRPCServer{Impl: p.Impl}, nil
}

func (ServeMuxPlugin) Client(b *plugin.MuxBroker, c *rpc.Client) (interface{}, error) {
	return &ServeMuxPluginRPC{client: c}, nil
}

// ServeMuxPluginRPCServer handles server-side RPC for plugins.
type ServeMuxPluginRPCServer struct {
	Impl RoutePlugin
}

func (s *ServeMuxPluginRPCServer) GetRoutes(args interface{}, resp []Route) error {
	routes, err := s.Impl.GetRoutes()
	if err != nil {
		return err
	}
	resp = routes
	return nil
}

// ServeMuxPluginRPC handles client-side RPC for plugins.
type ServeMuxPluginRPC struct {
	client *rpc.Client
}

func (g *ServeMuxPluginRPC) GetRoutes() ([]Route, error) {
	var resp []Route
	if err := g.client.Call("Plugin.GetRoutes", new(interface{}), resp); err != nil {
		return nil, err
	}
	return resp, nil
}
