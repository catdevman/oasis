package main

import (
	"context"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strings"

	"github.com/catdevman/oasis/server"
)

const pluginDir = "./plugins/" // Define the plugin directory here

func main() {
	// Create the server with DefaultMux
	mux := server.NewDefaultMux()
	server := server.NewServer(mux)

	// Start the server in a new goroutine
	go func() {
		if err := server.Start(context.Background(), ":8080"); err != nil {
			log.Fatal(err)
		}
	}()

	// Handle graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	go func() {
		<-quit
		log.Println("Shutting down server...")
		cancel()
	}()

	// Register a route to reload all plugins
	http.HandleFunc("/reload_plugins", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
			return
		}

		if err := loadPluginsFromDir(server, ctx, pluginDir); err != nil {
			http.Error(w, fmt.Sprintf("Failed to reload plugins: %v", err), http.StatusInternalServerError)
			return
		}

		fmt.Fprintln(w, "Plugins reloaded successfully")
	})

	// Load initial plugins from the plugin directory
	if err := loadPluginsFromDir(server, ctx, pluginDir); err != nil {
		log.Fatal(err)
	}

	// Wait for shutdown signal
	<-ctx.Done()
	log.Println("Server stopped")
}

// loadPluginsFromDir loads all plugins from the given directory.
func loadPluginsFromDir(server *server.Server, ctx context.Context, dir string) error {
	// Clear existing plugins
	server.ClearPlugins()

	var pluginPaths []string
	err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && strings.HasSuffix(path, ".so") {
			pluginPaths = append(pluginPaths, path)
		}
		return nil
	})
	if err != nil {
		return fmt.Errorf("failed to walk plugin directory: %w", err)
	}

	if err := server.LoadPlugins(ctx, pluginPaths); err != nil {
		return fmt.Errorf("failed to load plugins: %w", err)
	}

	return nil
}
