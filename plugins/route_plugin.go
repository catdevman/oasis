package plugins

import (
        "context"
        "net/http"
)

// RoutePlugin defines the interface for plugins that provide routes.
type RoutePlugin interface {
        // Routes returns the routes provided by the plugin.
        Routes(ctx context.Context) (Route, error)
}

// Route represents a single route provided by a plugin.
type Route struct {
        // Name is the name of the route.
        Name string
        // Method is the HTTP method of the route.
        Method string
        // Pattern is the URL pattern of the route.
        Pattern string
        // HandlerFunc is the handler function for the route.
        HandlerFunc http.HandlerFunc
}
