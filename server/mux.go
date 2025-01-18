package server

import "net/http"

// Muxer is an interface for HTTP multiplexers.
type Muxer interface {
	// Handle registers a handler for the given pattern and method.
	Handle(pattern string, handler http.Handler)
	// ServeHTTP dispatches the request to the handler whose
	// pattern most closely matches the request URL.
	ServeHTTP(w http.ResponseWriter, r *http.Request)
}

// DefaultMux is a concrete implementation of Muxer using http.ServeMux.
type DefaultMux struct {
	*http.ServeMux
}

// NewDefaultMux creates a new DefaultMux.
func NewDefaultMux() *DefaultMux {
	return &DefaultMux{http.NewServeMux()}
}
