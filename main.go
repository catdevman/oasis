package main

import (
	"log"
	"net/http"
	"os/exec"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

func main() {
	mux := http.NewServeMux()

	// Define the plugin map
	pluginMap := map[string]plugin.Plugin{
		"routePlugin": &shared.ServeMuxPlugin{},
	}

	// Load the plugin
	client := plugin.NewClient(&plugin.ClientConfig{
		HandshakeConfig: shared.Handshake,
		Plugins:         pluginMap,
		Cmd:             exec.Command("./plugins/plugin"),
	})

	defer client.Kill()

	rpcClient, err := client.Client()
	if err != nil {
		log.Fatalf("Error initializing plugin client: %v", err)
	}

	raw, err := rpcClient.Dispense("routePlugin")
	if err != nil {
		log.Fatalf("Error dispensing plugin: %v", err)
	}

	plugin := raw.(shared.RoutePlugin)
	routes, err := plugin.GetRoutes()
	if err != nil {
		log.Fatalf("Error retrieving routes from plugin: %v", err)
	}

	for _, route := range routes {
		mux.HandleFunc(route.Pattern, route.Handler)
	}

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
