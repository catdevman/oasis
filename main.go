package main

import (
	"io"
	"log"
	"net/http"
	"os/exec"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

func main() {
	// Register types for gob serialization.
	shared.RegisterTypes()

	mux := http.NewServeMux()

	// Define the plugin map.
	pluginMap := map[string]plugin.Plugin{
		"routePlugin": &shared.ServeMuxPlugin{},
	}

	// Start the plugin client.
	client := plugin.NewClient(&plugin.ClientConfig{
		HandshakeConfig: shared.HandshakeConfig,
		Plugins:         pluginMap,
		Cmd:             exec.Command("./plugins/plugin"), // Path to the plugin binary
	})
	defer client.Kill()

	// Get the RPC client.
	rpcClient, err := client.Client()
	if err != nil {
		log.Fatalf("Error initializing plugin client: %v", err)
	}

	// Dispense the plugin.
	raw, err := rpcClient.Dispense("routePlugin")
	if err != nil {
		log.Fatalf("Error dispensing plugin: %v", err)
	}

	// Cast the plugin to the RoutePlugin interface.
	plugin := raw.(shared.RoutePlugin)

	// Retrieve routes from the plugin.
	routes, err := plugin.GetRoutes()
	if err != nil {
		log.Fatalf("Error retrieving routes: %v", err)
	}

	// Register the routes in the main application.
	for _, route := range routes {
		handlerID := route.HandlerID
		mux.HandleFunc(route.Pattern, func(w http.ResponseWriter, r *http.Request) {
			// Serialize the request.
			body, _ := io.ReadAll(r.Body)
			req := shared.SerializedRequest{
				Method: r.Method,
				URL:    r.URL.String(),
				Header: r.Header,
				Body:   body,
			}

			// Call the plugin's HandleRequest method.
			res, err := plugin.HandleRequest(handlerID, req)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				return
			}

			// Write the response from the plugin.
			for key, values := range res.Header {
				for _, value := range values {
					w.Header().Add(key, value)
				}
			}
			w.WriteHeader(res.StatusCode)
			w.Write([]byte(res.Body))
		})
	}

	// Start the HTTP server.
	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
