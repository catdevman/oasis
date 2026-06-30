package errors

import (
	"errors"
	"fmt"
	"testing"
)

func TestKindString(t *testing.T) {
	tests := []struct {
		kind Kind
		want string
	}{
		{KindConfig, "config error"},
		{KindPlugin, "plugin error"},
		{KindDatabase, "database error"},
		{KindNotFound, "not found"},
		{KindInternal, "internal error"},
		{Kind(0), "unknown error"},
		{Kind(99), "unknown error"},
	}
	for _, tt := range tests {
		t.Run(tt.want, func(t *testing.T) {
			if got := tt.kind.String(); got != tt.want {
				t.Errorf("Kind(%d).String() = %q, want %q", tt.kind, got, tt.want)
			}
		})
	}
}

func TestOasisErrorError(t *testing.T) {
	err := &OasisError{
		Op:   "loadConfig",
		Kind: KindConfig,
		Err:  fmt.Errorf("file not found"),
	}
	want := "loadConfig: config error: file not found"
	if got := err.Error(); got != want {
		t.Errorf("Error() = %q, want %q", got, want)
	}
}

func TestOasisErrorErrorNilErr(t *testing.T) {
	err := &OasisError{
		Op:   "serveHTTP",
		Kind: KindNotFound,
		Err:  nil,
	}
	want := "serveHTTP: not found"
	if got := err.Error(); got != want {
		t.Errorf("Error() = %q, want %q", got, want)
	}
}

func TestOasisErrorUnwrap(t *testing.T) {
	underlying := fmt.Errorf("connection refused")
	err := &OasisError{
		Op:   "connectDB",
		Kind: KindDatabase,
		Err:  underlying,
	}
	if got := err.Unwrap(); got != underlying {
		t.Errorf("Unwrap() = %v, want %v", got, underlying)
	}
}

func TestOasisErrorUnwrapNil(t *testing.T) {
	err := &OasisError{
		Op:   "op",
		Kind: KindInternal,
		Err:  nil,
	}
	if got := err.Unwrap(); got != nil {
		t.Errorf("Unwrap() = %v, want nil", got)
	}
}

var errSentinel = fmt.Errorf("sentinel")

func TestErrorsIs(t *testing.T) {
	oErr := E("loadPlugin", KindPlugin, errSentinel)
	if !errors.Is(oErr, errSentinel) {
		t.Error("errors.Is should find the sentinel error through Unwrap")
	}
}

func TestErrorsAs(t *testing.T) {
	oErr := E("loadPlugin", KindPlugin, fmt.Errorf("bad plugin"))
	// Wrap it in another error to test errors.As traversal
	wrapped := fmt.Errorf("wrapper: %w", oErr)

	var target *OasisError
	if !errors.As(wrapped, &target) {
		t.Fatal("errors.As should find *OasisError in the chain")
	}
	if target.Op != "loadPlugin" {
		t.Errorf("Op = %q, want %q", target.Op, "loadPlugin")
	}
	if target.Kind != KindPlugin {
		t.Errorf("Kind = %v, want %v", target.Kind, KindPlugin)
	}
}

func TestEConstructor(t *testing.T) {
	underlying := fmt.Errorf("timeout")
	oErr := E("queryDB", KindDatabase, underlying)

	if oErr.Op != "queryDB" {
		t.Errorf("Op = %q, want %q", oErr.Op, "queryDB")
	}
	if oErr.Kind != KindDatabase {
		t.Errorf("Kind = %v, want %v", oErr.Kind, KindDatabase)
	}
	if oErr.Err != underlying {
		t.Errorf("Err = %v, want %v", oErr.Err, underlying)
	}
}

func TestEConstructorNilErr(t *testing.T) {
	oErr := E("init", KindInternal, nil)
	if oErr.Err != nil {
		t.Errorf("Err = %v, want nil", oErr.Err)
	}
	// Should not panic
	_ = oErr.Error()
}
