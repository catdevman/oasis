package main

import (
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"

	"github.com/catdevman/oasis/internal/db"
	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-plugin"
	"gopkg.in/yaml.v3"
)

type AppConfig struct {
	Database db.Config      `yaml:"database"`
	Plugins  []PluginConfig `yaml:"plugins"`
}
type PluginConfig struct {
	Name   string `yaml:"name"`
	Path   string `yaml:"path"`
	Prefix string `yaml:"prefix"`
	Tables string `yaml:"tables"`
}

var pluginClients = make(map[string]shared.HTTPPlugin)
var plugs = []*plugin.Client{}
var menuItems = []shared.MenuItem{}
var uiTemplate *template.Template

func main() {
	// Parse the host UI template
	var err error
	uiTemplate, err = template.ParseFiles("ui/layout.html")
	if err != nil {
		log.Fatalf("Failed to parse ui/layout.html: %v", err)
	}

	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
	config, err := loadConfig("plugins.yaml")
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize database and run migrations
	database, err := db.Open(config.Database)
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}
	database.Close()

	loadPlugins(config)

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
		for _, p := range plugs {
			p.Kill()
		}
		os.Exit(0)
	}()
	log.Fatal(http.ListenAndServe(":8080", masterHandler))
}

type LayoutData struct {
	MenuItems   []shared.MenuItem
	InitialPath string
}

func router(w http.ResponseWriter, r *http.Request) {
	path := strings.Trim(r.URL.Path, "/")
	isHTMX := r.Header.Get("HX-Request") == "true"

	// 1. Determine the role
	role := r.URL.Query().Get("role")
	if role != "" {
		http.SetCookie(w, &http.Cookie{
			Name:  "role",
			Value: role,
			Path:  "/",
		})
	} else {
		cookie, err := r.Cookie("role")
		if err == nil {
			role = cookie.Value
		}
	}
	if role == "" {
		role = "admin" // Default to admin for dev
	}

	// Host-level UI Authorization check
	matchedMenu := false
	var requiredRoles []string
	for _, item := range menuItems {
		// Exact match or prefix match (e.g. /students or /students/123)
		if "/"+path == item.Path || strings.HasPrefix("/"+path, item.Path+"/") {
			matchedMenu = true
			requiredRoles = item.AllowedRoles
			break
		}
	}

	if matchedMenu {
		allowed := false
		for _, allowedRole := range requiredRoles {
			if allowedRole == role || allowedRole == "*" {
				allowed = true
				break
			}
		}
		if !allowed {
			http.Error(w, "403 Forbidden: You do not have permission to view this page", http.StatusForbidden)
			return
		}
	}

	// If root, dashboard, or a direct browser navigation to a UI route, serve the shell
	if !isHTMX && (path == "" || path == "dashboard" || r.Method == http.MethodGet && !strings.HasPrefix(path, "api/")) {
		w.Header().Set("Content-Type", "text/html")
		
		initialPath := r.URL.Path
		if path == "" || path == "dashboard" {
			initialPath = "/overview" // Default route
		}
		
		var filteredMenu []shared.MenuItem
		for _, item := range menuItems {
			allowed := false
			for _, allowedRole := range item.AllowedRoles {
				if allowedRole == role {
					allowed = true
					break
				}
			}
			if allowed {
				filteredMenu = append(filteredMenu, item)
			}
		}

		uiTemplate.Execute(w, LayoutData{
			MenuItems:   filteredMenu,
			InitialPath: initialPath,
		})
		return
	}

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
	log.Printf("Routing request for %s to matched prefix '%s'", r.URL.Path, bestMatch)

	// We pass the EXACT original path down to the plugin so it can register absolute paths!
	// (No longer stripping the prefix here)
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read request body", http.StatusInternalServerError)
		return
	}

	if r.Header == nil {
		r.Header = make(http.Header)
	}
	r.Header.Set("X-User-Role", role)

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

func loadPlugins(config *AppConfig) {
	for _, p := range config.Plugins {
		log.Printf("Loading plugin '%s' from path %s", p.Name, p.Path)

		cmd := exec.Command(p.Path)
		cmd.Env = append(os.Environ(),
			"OASIS_DB_URL="+config.Database.URL,
			"OASIS_PLUGIN_NAME="+p.Name,
			"OASIS_PLUGIN_PREFIX="+p.Prefix,
		)

		client := plugin.NewClient(&plugin.ClientConfig{
			HandshakeConfig: shared.Handshake,
			Plugins:         map[string]plugin.Plugin{"http_plugin": &shared.HTTPPluginAdapter{}},
			Cmd:             cmd,
		})
		plugs = append(plugs, client)
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
		
		httpPlugin := raw.(shared.HTTPPlugin)
		pluginClients[p.Prefix] = httpPlugin
		
		// Ask the plugin if it wants to claim additional top-level routes
		dynamicRoutes, err := httpPlugin.GetRoutes()
		if err == nil {
			for _, r := range dynamicRoutes {
				cleanRoute := strings.TrimPrefix(r, "/")
				pluginClients[cleanRoute] = httpPlugin
				log.Printf("- %s dynamically registered route -> /%s/*", p.Name, cleanRoute)
			}
		} else {
			log.Printf("Plugin %s GetRoutes err: %v", p.Name, err)
		}

		// Ask the plugin for its Menu Items
		items, err := httpPlugin.GetMenuItems()
		if err == nil && len(items) > 0 {
			menuItems = append(menuItems, items...)
			log.Printf("- %s registered %d menu items", p.Name, len(items))
		}
	}
}
