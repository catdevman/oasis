package shared

import (
	"encoding/gob"
	"net/http"
	"net/rpc"

	"github.com/hashicorp/go-plugin"
)

// SerializedRequest contains the parts of http.Request to send over RPC.
type SerializedRequest struct {
	Method string
	URL    string
	Header http.Header
	Body   []byte
}

// SerializedResponse contains the plugin's response data.
type SerializedResponse struct {
	StatusCode int
	Header     http.Header
	Body       string
}

// Route defines a route with method, pattern, and handler ID.
type Route struct {
	Method    string // HTTP method, e.g., "GET"
	Pattern   string // URL pattern, e.g., "/hello"
	HandlerID string // Identifier for the handler function
}

// RoutePlugin is the interface the plugin must implement.
type RoutePlugin interface {
	GetRoutes() ([]Route, error)
	HandleRequest(handlerID string, req SerializedRequest) (SerializedResponse, error)
}

// RegisterTypes registers all custom types with gob for RPC serialization.
func RegisterTypes() {
	gob.Register(SerializedRequest{})
	gob.Register(SerializedResponse{})
}

// ServeMuxPlugin is the plugin implementation for hashicorp/go-plugin.
type ServeMuxPlugin struct {
	Impl RoutePlugin
}

func (p *ServeMuxPlugin) Server(*plugin.MuxBroker) (interface{}, error) {
	return &ServeMuxPluginRPCServer{Impl: p.Impl}, nil
}

func (p *ServeMuxPlugin) Client(b *plugin.MuxBroker, c *rpc.Client) (interface{}, error) {
	return &ServeMuxPluginRPC{client: c}, nil
}

// ServeMuxPluginRPCServer is the RPC server.
type ServeMuxPluginRPCServer struct {
	Impl RoutePlugin
}

func (s *ServeMuxPluginRPCServer) GetRoutes(args interface{}, resp *[]Route) error {
	routes, err := s.Impl.GetRoutes()
	if err != nil {
		return err
	}
	*resp = routes
	return nil
}

func (s *ServeMuxPluginRPCServer) HandleRequest(args map[string]interface{}, resp *SerializedResponse) error {
	handlerID := args["handlerID"].(string)
	req := args["request"].(SerializedRequest)
	res, err := s.Impl.HandleRequest(handlerID, req)
	if err != nil {
		return err
	}
	*resp = res
	return nil
}

// ServeMuxPluginRPC is the RPC client.
type ServeMuxPluginRPC struct {
	client *rpc.Client
}

func (g *ServeMuxPluginRPC) GetRoutes() ([]Route, error) {
	var resp []Route
	if err := g.client.Call("Plugin.GetRoutes", new(interface{}), &resp); err != nil {
		return nil, err
	}
	return resp, nil
}

func (g *ServeMuxPluginRPC) HandleRequest(handlerID string, req SerializedRequest) (SerializedResponse, error) {
	args := map[string]interface{}{
		"handlerID": handlerID,
		"request":   req,
	}
	var resp SerializedResponse
	if err := g.client.Call("Plugin.HandleRequest", args, &resp); err != nil {
		return SerializedResponse{}, err
	}
	return resp, nil
}

// HandshakeConfig ensures client-server compatibility.
var HandshakeConfig = plugin.HandshakeConfig{
	ProtocolVersion:  1,
	MagicCookieKey:   "ROUTE_PLUGIN",
	MagicCookieValue: "dynamic-api",
}
