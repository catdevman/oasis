package server

import (
	"context"
	"fmt"

	"github.com/catdevman/oasis/plugins"
	"github.com/hashicorp/go-hclog"
	"github.com/hashicorp/go-plugin"
	"google.golang.org/grpc"

	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"sync"
)

// Server is a web server that can load plugins.
type Server struct {
	mux           Muxer
	plugins       []plugins.RoutePlugin
	pluginLoaders *plugin.Client
	pluginMutex   sync.RWMutex
	grpcServer    *plugin.GRPCServer
	grpcListener  net.Listener
}

// NewServer creates a new Server.
func NewServer(mux DefaultMux) *Server {
	return &Server{
		mux: mux,
	}
}

// Start starts the server.
func (s *Server) Start(ctx context.Context, addr string) error {
	// Start the gRPC server for plugins
	var err error
	s.grpcListener, err = net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return fmt.Errorf("failed to start gRPC listener: %w", err)
	}
	s.grpcServer = plugin.DefaultGRPCServer()
	go s.grpcServer.Serve(s.grpcListener)

	// Start the HTTP server
	log.Println("Starting server on", addr)
	return http.ListenAndServe(addr, s.mux)
}

// LoadPlugins loads new plugins without shutting down the server.
func (s *Server) LoadPlugins(ctx context.Context, pluginPaths []string) error {
	s.pluginMutex.Lock()
	defer s.pluginMutex.Unlock()

	if err := s.loadPlugins(ctx, pluginPaths); err != nil {
		return err
	}

	s.registerRoutes(ctx)
	return nil
}

// loadPlugins loads plugins from the given paths.
func (s *Server) loadPlugins(ctx context.Context, pluginPaths []string) error {
	for _, path := range pluginPaths {
		// Check if plugin is already loaded
		if s.isPluginLoaded(path) {
			continue
		}

		// Launch the plugin process
		cmd := exec.Command(path)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Start(); err != nil {
			return fmt.Errorf("failed to start plugin %s: %w", path, err)
		}

		// Connect to the plugin
		client, err := s.connectPlugin(ctx, path)
		if err != nil {
			return fmt.Errorf("failed to connect to plugin %s: %w", path, err)
		}

		// Get the plugin's routes
		raw, err := client.Dispense("sample_plugin")
		if err != nil {
			return fmt.Errorf("failed to dispense plugin %s: %w", path, err)
		}

		// Convert the plugin to the RoutePlugin interface
		plugin, ok := raw.(RoutePlugin)
		if !ok {
			return fmt.Errorf("plugin %s does not implement RoutePlugin interface", path)
		}

		s.plugins = append(s.plugins, plugin)
		s.pluginLoaders = append(s.pluginLoaders, client)
	}
	return nil
}

// connectPlugin connects to a plugin at the given path.
func (s *Server) connectPlugin(ctx context.Context, path string) (*plugin.Client, error) {
	hostname, err := os.Hostname()
	if err != nil {
		return nil, err
	}
	return plugin.NewClient(&plugin.ClientConfig{
		HandshakeConfig: plugin.HandshakeConfig{
			ProtocolVersion:  1,
			MagicCookieKey:   "PLUGIN_MAGIC_COOKIE",
			MagicCookieValue: "hello",
		},
		Plugins: map[string]plugin.Plugin{
			"sample_plugin": &RoutePluginImpl{},
		},
		Cmd:              exec.Command(path),
		AllowedProtocols: plugin.Protocol{plugin.ProtocolGRPC},
		Managed:          true,
		Context:          ctx,
		Logger:           NewHCLogAdapter(plugin.NewLoggableFromContext(ctx)),
		AutoMTLS:         true,
		Hostname:         hostname,
	}), nil
}

// isPluginLoaded checks if a plugin is already loaded.
func (s *Server) isPluginLoaded(path string) bool {
	for _, p := range s.plugins {
		if rp, ok := p.(*RoutePluginImpl); ok {
			if strings.HasPrefix(rp.Impl.PluginLocation, path) {
				return true
			}
		}
	}
	return false
}

// registerRoutes registers the routes from all loaded plugins.
func (s *Server) registerRoutes(ctx context.Context) {
	for _, p := range s.plugins {
		routes, err := p.Routes(ctx)
		if err != nil {
			log.Printf("Failed to get routes from plugin: %v", err)
			continue
		}
		for _, route := range routes {
			s.mux.Handle(route.Pattern, route.Method, route.HandlerFunc)
			log.Printf("Registered route: %s %s", route.Method, route.Pattern)
		}
	}
}

// RoutePluginImpl is a wrapper for the RoutePlugin interface that allows us to
// use the plugin package's GRPC server.
type RoutePluginImpl struct {
	plugin.Plugin
	Impl RoutePlugin
}

func (p *RoutePluginImpl) GRPCServer(broker *plugin.GRPCBroker, s *plugin.GRPCServer) error {
	return nil
}

func (p *RoutePluginImpl) GRPCClient(ctx context.Context, broker *plugin.GRPCBroker, c *plugin.GRPCClient) (interface{}, error) {
	return nil, nil
}

type HCLogAdapter struct {
	hclog.Logger
}

func NewHCLogAdapter(logger hclog.Logger) *HCLogAdapter {
	return &HCLogAdapter{logger}
}

func (a *HCLogAdapter) Printf(format string, v ...interface{}) {
	a.Logger.Info(fmt.Sprintf(format, v...))
}
