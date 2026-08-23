package web

import (
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func get(t *testing.T, h http.Handler, path string) (int, string) {
	t.Helper()
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
	body, _ := io.ReadAll(rec.Result().Body)
	return rec.Code, string(body)
}

func TestSurface(t *testing.T) {
	h := New("test", slog.New(slog.NewTextHandler(io.Discard, nil))).Handler()
	if code, body := get(t, h, "/healthz"); code != 200 || strings.TrimSpace(body) != "ok" {
		t.Fatalf("healthz: %d %q", code, body)
	}
	if code, body := get(t, h, "/metrics"); code != 200 || !strings.Contains(body, `arcade_build_info{version="test"} 1`) {
		t.Fatalf("metrics: %d %q", code, body)
	}
	if code, body := get(t, h, "/"); code != 200 || !strings.Contains(body, "logo-animated.svg") {
		t.Fatalf("home: %d", code)
	}
	if code, _ := get(t, h, "/static/logo-animated.svg"); code != 200 {
		t.Fatalf("static: %d", code)
	}
	if code, _ := get(t, h, "/nope"); code != 404 {
		t.Fatalf("unknown path: %d", code)
	}
}
