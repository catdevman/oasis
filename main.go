package main

import (
	"fmt"
	"log"
	"os/exec"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

// PluginMap is the map of plugins we can dispense.
var PluginMap = map[string]plugin.Plugin{
	"greeter": &shared.GreeterPlugin{},
}

func main() {
	// We're a host! Start by launching the plugin process.
	client := plugin.NewClient(&plugin.ClientConfig{
		HandshakeConfig: shared.Handshake,
		Plugins:         PluginMap,
		Cmd:             exec.Command("./plugin/greeter"),
	})
	defer client.Kill()

	// Connect via RPC
	rpcClient, err := client.Client()
	if err != nil {
		log.Fatal(err)
	}

	// Request the plugin
	raw, err := rpcClient.Dispense("greeter")
	if err != nil {
		log.Fatal(err)
	}

	// We should have a Greeter now! This feels like a normal interface
	// implementation but is in fact over an RPC connection.
	greeter := raw.(shared.Router)
	fmt.Println(greeter.Routes())
}
