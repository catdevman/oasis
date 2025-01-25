package main

import (
	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

// Here is a real implementation of Greeter
type MyGreeter struct {
}

func (g *MyGreeter) Greet() string {
	return "Hello!"
}

func (g *MyGreeter) Routes() []shared.Route {
	return []shared.Route{
		{
			Name:    "something",
			Pattern: "GET /something",
		},
	}
}

func main() {
	greeter := &MyGreeter{}
	// pluginMap is the map of plugins we can dispense.
	var pluginMap = map[string]plugin.Plugin{
		"greeter": &shared.GreeterPlugin{Impl: greeter},
	}

	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins:         pluginMap,
	})
}
