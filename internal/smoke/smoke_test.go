// Package smoke exercises the plugin contract end to end.
//
// go build proves the plugin packages compile; it proves nothing about the
// contract they actually have to satisfy, which is a net/rpc conversation with
// a handshake over a subprocess. A broken magic cookie, a renamed RPC method or
// a changed HTTPRequest field all compile cleanly and only fail once the host
// launches the plugin. That is what these tests cover.
package smoke

import (
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/catdevman/oasis/shared"
	"github.com/hashicorp/go-hclog"
	"github.com/hashicorp/go-plugin"
)

// rpcTimeout bounds a single call to a plugin. It is generous for a local
// subprocess: the point is to catch a call that will never return, not to
// measure latency.
const rpcTimeout = 15 * time.Second

// needsDB lists plugins whose New() opens a database at construction time and
// panics when one is not reachable. They are skipped unless OASIS_DB_URL is
// set; CI points it at a Postgres service. Only connectivity is required, not
// a schema, since nothing queries during startup.
var needsDB = map[string]bool{
	"common": true,
}

// TestPluginsLoad builds every main package under plugin/ and drives each one
// through the handshake, Dispense, and all three RPC methods. Plugins are
// discovered rather than listed, so a newly added plugin directory is covered
// without touching this file.
func TestPluginsLoad(t *testing.T) {
	root := repoRoot(t)
	binDir := t.TempDir()

	build := exec.Command("go", "build", "-o", binDir+string(os.PathSeparator), "./plugin/...")
	build.Dir = root
	if out, err := build.CombinedOutput(); err != nil {
		t.Fatalf("building plugins: %v\n%s", err, out)
	}

	entries, err := os.ReadDir(binDir)
	if err != nil {
		t.Fatalf("reading built plugins: %v", err)
	}
	if len(entries) == 0 {
		t.Fatal("./plugin/... produced no binaries")
	}

	dbURL := os.Getenv("OASIS_DB_URL")
	for _, entry := range entries {
		name := entry.Name()
		t.Run(name, func(t *testing.T) {
			if needsDB[name] && dbURL == "" {
				t.Skip("needs a database; set OASIS_DB_URL to run")
			}
			exercisePlugin(t, filepath.Join(binDir, name))
		})
	}
}

// exercisePlugin launches one plugin binary the same way main.go does and calls
// every method on the dispensed client.
func exercisePlugin(t *testing.T, bin string) {
	client := plugin.NewClient(&plugin.ClientConfig{
		HandshakeConfig: shared.Handshake,
		Plugins:         shared.PluginMap,
		Cmd:             exec.Command(bin),
		// go-plugin defaults to a trace-level logger on stderr, which buries
		// the test output.
		Logger: hclog.New(&hclog.LoggerOptions{Output: io.Discard}),
		// Default is a minute per plugin. A plugin that wedges on startup
		// should report quickly rather than stall the whole job.
		StartTimeout: 30 * time.Second,
	})
	defer client.Kill()

	rpcClient, err := client.Client()
	if err != nil {
		t.Fatalf("handshake failed: %v", err)
	}

	raw, err := rpcClient.Dispense("http_plugin")
	if err != nil {
		t.Fatalf("dispensing http_plugin: %v", err)
	}

	impl, ok := raw.(shared.HTTPPlugin)
	if !ok {
		t.Fatalf("dispensed %T, want shared.HTTPPlugin", raw)
	}

	// The host calls both of these on every plugin at load time, and tolerates
	// an empty result but not an error.
	mustReturn(t, "GetRoutes", func() error {
		_, err := impl.GetRoutes()
		return err
	})
	mustReturn(t, "GetMenuItems", func() error {
		_, err := impl.GetMenuItems()
		return err
	})

	// Round-trip a request so a break in the HTTPRequest/HTTPResponse encoding
	// surfaces here. The path is deliberately unrouted: any status will do, the
	// point is that the call completes and comes back populated.
	mustReturn(t, "ServeHTTP", func() error {
		resp, err := impl.ServeHTTP(shared.HTTPRequest{
			Method: http.MethodGet,
			URL:    "/oasis-smoke-test-unrouted",
			Header: http.Header{},
		})
		if err != nil {
			return err
		}
		if resp.StatusCode == 0 {
			t.Error("ServeHTTP returned a zero StatusCode")
		}
		return nil
	})
}

// mustReturn calls fn and fails if it errors or never comes back.
//
// The timeout is not belt-and-braces. net/rpc does not reject a call to a
// method the other side does not have — it blocks, forever. A plugin built
// against an incompatible version of shared therefore hangs the caller rather
// than reporting a mismatch, so an unbounded call here would stall until the
// go test timeout and report it as a ten-minute test failure instead of a
// broken plugin contract.
func mustReturn(t *testing.T, name string, fn func() error) {
	t.Helper()

	done := make(chan error, 1)
	go func() { done <- fn() }()

	select {
	case err := <-done:
		if err != nil {
			t.Errorf("%s: %v", name, err)
		}
	case <-time.After(rpcTimeout):
		t.Fatalf("%s: no response after %s; the plugin's RPC surface most likely "+
			"does not match shared.HTTPPlugin", name, rpcTimeout)
	}
}

func repoRoot(t *testing.T) string {
	t.Helper()

	dir, err := filepath.Abs(filepath.Join("..", ".."))
	if err != nil {
		t.Fatalf("resolving repo root: %v", err)
	}
	if _, err := os.Stat(filepath.Join(dir, "go.mod")); err != nil {
		t.Fatalf("expected the repo root at %s: %v", dir, err)
	}
	return dir
}
