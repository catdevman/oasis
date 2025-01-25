package shared

import (
	"net/http"
	"net/rpc"

	"github.com/hashicorp/go-plugin"
)

// Handshake is a common handshake that is shared by plugin and host.
var Handshake = plugin.HandshakeConfig{
	ProtocolVersion:  1,
	MagicCookieKey:   "BASIC_PLUGIN",
	MagicCookieValue: "hello",
}

type Both interface {
	Router
	Greeter
}

type Route struct {
	Name    string
	Pattern string
	Handle  http.HandlerFunc
}
type Greeter interface {
	Greet() string
}

type Router interface {
	Routes() []Route
}

type GreeterPlugin struct {
	// Impl Injection
	Impl Both
}

func (p *GreeterPlugin) Server(*plugin.MuxBroker) (interface{}, error) {
	return &RPCServer{Impl: p.Impl}, nil
}

func (GreeterPlugin) Client(b *plugin.MuxBroker, c *rpc.Client) (interface{}, error) {
	return &RPCClient{client: c}, nil
}

type RPCServer struct {
	// This is the real implementation
	Impl Both
}

func (s *RPCServer) Greet(args interface{}, resp *string) error {
	*resp = s.Impl.Greet()
	return nil
}

func (s *RPCServer) Routes(args interface{}, resp []Route) error {
	resp = s.Impl.Routes()
	return nil
}

type RPCClient struct {
	client *rpc.Client
}

func (c *RPCClient) Greet() string {
	var resp string
	err := c.client.Call("Plugin.Greet", new(interface{}), &resp)
	if err != nil {
		// You usually want your interfaces to return errors. If they don't,
		// there isn't much other choice here.
		panic(err)
	}

	return resp
}

func (c *RPCClient) Routes() []Route {
	var resp []Route
	err := c.client.Call("Plugin.Routes", new(interface{}), &resp)
	if err != nil {
		// You usually want your interfaces to return errors. If they don't,
		// there isn't much other choice here.
		panic(err)
	}

	return resp
}
