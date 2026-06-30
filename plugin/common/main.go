package main

import (
	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

func main() {
	plugin.Serve(&plugin.ServeConfig{
		HandshakeConfig: shared.Handshake,
		Plugins: map[string]plugin.Plugin{
			"http_plugin": &shared.HTTPPluginAdapter{Impl: New()},
		},
	})
}
