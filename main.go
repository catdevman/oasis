package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"syscall"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

// Exit codes
const (
	EXIT_SUCCESSFUL = iota
	EXIT_PLUGINS_FAILED
)

func main() {
	// Register types for gob serialization.
	shared.RegisterTypes()

	mux := http.NewServeMux()
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
	// Define the plugin map.
	pluginMap := map[string]plugin.Plugin{
		"routePlugin": &shared.ServeMuxPlugin{},
	}
	//TODO: this should be configurable
	dir := "./plugins"
	executables, err := findExecutables(dir)
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(EXIT_PLUGINS_FAILED)
	}
	plugs := []*plugin.Client{}
	for _, exe := range executables {

		// Start the plugin client.
		client := plugin.NewClient(&plugin.ClientConfig{
			HandshakeConfig: shared.HandshakeConfig,
			Plugins:         pluginMap,
			Cmd:             exec.Command(exe), // Path to the plugin binary
		})
		defer client.Kill()
		plugs = append(plugs, client)

		// Get the RPC client.
		rpcClient, err := client.Client()
		if err != nil {
			log.Fatalf("Error initializing plugin client: %v @ %v", err, exe)
		}

		// Dispense the plugin.
		raw, err := rpcClient.Dispense("routePlugin")
		if err != nil {
			log.Fatalf("Error dispensing plugin: %v @ %v", err, exe)
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
	}
	go func() {
		sig := <-c
		fmt.Println("Received signal:", sig)
		fmt.Println("Shutting down gracefully...")
		for _, p := range plugs {
			p.Kill()
		}
		os.Exit(0)
	}()
	// Start the HTTP server.
	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

// findExecutables returns a slice of executable file paths in the given directory
func findExecutables(root string) ([]string, error) {
	var executables []string

	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// Check if the file is a regular file and has executable permissions
		if !info.IsDir() && (info.Mode()&0111 != 0) {
			executables = append(executables, path)
		}
		return nil
	})

	return executables, err
}
