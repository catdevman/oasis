package shared

import (
	"net/http"
)

// Route defines an individual route with method, pattern, and handler function.
type Route struct {
	Method  string           // e.g., "GET", "POST"
	Pattern string           // e.g., "/api/resource"
	Handler http.HandlerFunc // The actual handler function provided by the plugin
}
