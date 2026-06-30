package errors

import "fmt"

// Kind categorizes errors in the Oasis system.
type Kind int

const (
	KindConfig   Kind = iota + 1 // config file errors
	KindPlugin                   // plugin loading/communication errors
	KindDatabase                 // database errors
	KindNotFound                 // route/resource not found
	KindInternal                 // internal/unexpected errors
)

func (k Kind) String() string {
	switch k {
	case KindConfig:
		return "config error"
	case KindPlugin:
		return "plugin error"
	case KindDatabase:
		return "database error"
	case KindNotFound:
		return "not found"
	case KindInternal:
		return "internal error"
	default:
		return "unknown error"
	}
}

// OasisError is the standard error type for the Oasis system.
type OasisError struct {
	Op   string // the operation that failed (e.g., "loadConfig", "serveHTTP")
	Kind Kind   // categorizes the error
	Err  error  // the underlying wrapped error
}

func (e *OasisError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("%s: %s: %s", e.Op, e.Kind, e.Err.Error())
	}
	return fmt.Sprintf("%s: %s", e.Op, e.Kind)
}

func (e *OasisError) Unwrap() error {
	return e.Err
}

// E constructs a new OasisError.
func E(op string, kind Kind, err error) *OasisError {
	return &OasisError{
		Op:   op,
		Kind: kind,
		Err:  err,
	}
}
