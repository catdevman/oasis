// file: shared/plugin.go
package shared

import (
	"net/http"
	"net/rpc"

	"github.com/hashicorp/go-plugin"
)

// HTTPRequest is the serializable structure that represents an incoming HTTP request.
type HTTPRequest struct {
	Method string
	URL    string
	Header http.Header
	Body   []byte
}

// HTTPResponse is the serializable structure that represents an HTTP response.
type HTTPResponse struct {
	StatusCode int
	Header     http.Header
	Body       []byte
}

// HTTPPlugin is the interface that all our HTTP plugins must implement.
type HTTPPlugin interface {
	ServeHTTP(req HTTPRequest) (HTTPResponse, error)
}

// --- Boilerplate for hashicorp/go-plugin ---

// Here is the RPC server that HTTPPluginRPC talks to, conforming to
// the requirements of net/rpc.
type HTTPPluginRPCServer struct {
	Impl HTTPPlugin
}

func (s *HTTPPluginRPCServer) ServeHTTP(req HTTPRequest, resp *HTTPResponse) error {
	res, err := s.Impl.ServeHTTP(req)
	if err != nil {
		return err
	}
	*resp = res
	return nil
}

// Here is the RPC client that the host will use to talk to the plugin.
type HTTPPluginRPC struct{ client *rpc.Client }

func (g *HTTPPluginRPC) ServeHTTP(req HTTPRequest) (HTTPResponse, error) {
	var resp HTTPResponse
	err := g.client.Call("Plugin.ServeHTTP", req, &resp)
	if err != nil {
		// You may want to wrap the error in something more specific.
		return HTTPResponse{}, err
	}
	return resp, nil
}

// Handshake is a common handshake that is shared by plugin and host.
var Handshake = plugin.HandshakeConfig{
	ProtocolVersion:  1,
	MagicCookieKey:   "HTTP_PLUGIN",
	MagicCookieValue: "hello",
}

// PluginMap is the map of plugins we can dispense.
var PluginMap = map[string]plugin.Plugin{
	"http_plugin": &HTTPPluginAdapter{},
}

type HTTPPluginAdapter struct {
	Impl HTTPPlugin
}

func (p *HTTPPluginAdapter) Server(*plugin.MuxBroker) (interface{}, error) {
	return &HTTPPluginRPCServer{Impl: p.Impl}, nil
}

func (p *HTTPPluginAdapter) Client(b *plugin.MuxBroker, c *rpc.Client) (interface{}, error) {
	return &HTTPPluginRPC{client: c}, nil
}
