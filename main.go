package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"

	"gopkg.in/yaml.v3"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
)

type AppConfig struct {
	Plugins []PluginConfig `yaml:"plugins"`
}
type PluginConfig struct {
	Name   string `yaml:"name"`
	Path   string `yaml:"path"`
	Prefix string `yaml:"prefix"`
}

var pluginClients = make(map[string]shared.HTTPPlugin)

func main() {
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
	config, err := loadConfig("plugins.yaml")
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	loadPlugins(config.Plugins)

	masterHandler := http.HandlerFunc(router)

	log.Println("Host server listening on :8080")
	log.Println("Loaded routes from config:")
	for _, p := range config.Plugins {
		log.Printf("- %s -> /%s/*\n", p.Name, p.Prefix)
	}
	go func() {
		sig := <-c
		fmt.Println("Received signal:", sig)
		fmt.Println("Shutting down gracefully...")
		plugin.CleanupClients()
		os.Exit(0)
	}()
	log.Fatal(http.ListenAndServe(":8080", masterHandler))
}

func router(w http.ResponseWriter, r *http.Request) {
	path := strings.Trim(r.URL.Path, "/")

	var bestMatch string
	for prefix := range pluginClients {
		if strings.HasPrefix(path, prefix) {
			if len(prefix) > len(bestMatch) {
				bestMatch = prefix
			}
		}
	}

	if bestMatch == "" {
		http.Error(w, "404 Not Found: No plugin registered for this path", http.StatusNotFound)
		return
	}

	client := pluginClients[bestMatch]
	log.Printf("Routing request for %s to prefix '%s'", r.URL.Path, bestMatch)

	// Strip the prefix so the plugin receives the path relative to its root
	r.URL.Path = "/" + strings.TrimPrefix(strings.TrimPrefix(path, bestMatch), "/")

	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read request body", http.StatusInternalServerError)
		return
	}

	req := shared.HTTPRequest{
		Method: r.Method, URL: r.URL.String(), Header: r.Header, Body: body,
	}

	resp, err := client.ServeHTTP(req)
	if err != nil {
		http.Error(w, fmt.Sprintf("Plugin error: %s", err), http.StatusInternalServerError)
		return
	}

	for key, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(key, value)
		}
	}
	w.WriteHeader(resp.StatusCode)
	w.Write(resp.Body)
}

func loadConfig(path string) (*AppConfig, error) {
	configFile, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("could not read config file: %w", err)
	}
	var config AppConfig
	if err = yaml.Unmarshal(configFile, &config); err != nil {
		return nil, fmt.Errorf("could not parse yaml config: %w", err)
	}
	return &config, nil
}

func loadPlugins(configs []PluginConfig) {
	for _, p := range configs {
		log.Printf("Loading plugin '%s' from path %s", p.Name, p.Path)
		client := plugin.NewClient(&plugin.ClientConfig{
			HandshakeConfig: shared.Handshake,
			Plugins:         map[string]plugin.Plugin{"http_plugin": &shared.HTTPPluginAdapter{}},
			Cmd:             exec.Command(p.Path),
		})

		rpcClient, err := client.Client()
		if err != nil {
			log.Printf("Error creating RPC client for %s: %s", p.Name, err)
			continue
		}

		raw, err := rpcClient.Dispense("http_plugin")
		if err != nil {
			log.Printf("Error dispensing plugin %s: %s", p.Name, err)
			continue
		}
		pluginClients[p.Prefix] = raw.(shared.HTTPPlugin)
	}
}
