// Package web is the doorman's HTTP surface. v0.1: health, metrics, a
// placeholder front page. The play page, the knock, the relay land at G2.
package web

import (
	"fmt"
	"html/template"
	"log/slog"
	"net/http"
	"time"

	"github.com/tomblancdev/arcade/ui"
)

// Server holds what every handler needs.
type Server struct {
	version string
	started time.Time
	log     *slog.Logger
	page    *template.Template
}

// New builds a Server for the given build version.
func New(version string, log *slog.Logger) *Server {
	return &Server{
		version: version,
		started: time.Now(),
		log:     log,
		page:    template.Must(template.New("home").Parse(homeHTML)),
	}
}

// Handler routes the doorman's surface.
func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", s.healthz)
	mux.HandleFunc("GET /metrics", s.metrics)
	mux.Handle("GET /static/", http.StripPrefix("/static/", http.FileServerFS(ui.Static)))
	mux.HandleFunc("GET /{$}", s.home)
	return mux
}

func (s *Server) healthz(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprintln(w, "ok")
}

// metrics is the Prometheus text exposition, hand-written: the doorman's
// counters (sessions, wakes, open windows) join here at G2.
func (s *Server) metrics(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
	fmt.Fprintf(w, "# HELP arcade_build_info Build information of the doorman.\n# TYPE arcade_build_info gauge\narcade_build_info{version=%q} 1\n", s.version)
	fmt.Fprintf(w, "# HELP arcade_uptime_seconds Seconds since the doorman started.\n# TYPE arcade_uptime_seconds gauge\narcade_uptime_seconds %d\n", int64(time.Since(s.started).Seconds()))
}

func (s *Server) home(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := s.page.Execute(w, map[string]string{"Version": s.version}); err != nil {
		s.log.Error("render", "err", err)
	}
}

const homeHTML = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>L'Arcade</title>
<style>body{margin:0;background:#0a0b0e;color:#e9e6dc;font-family:"IBM Plex Mono",ui-monospace,Menlo,Consolas,monospace;display:grid;place-items:center;min-height:100vh}
main{max-width:640px;padding:24px}img{max-width:100%;height:auto}p{color:#7d8390}code{color:#c8ff00}</style></head>
<body><main><img src="/static/logo-animated.svg" alt="Le Squat — l'arcade // insert coin" width="640" height="200">
<p>The doorman is here, the play page is not yet. <code>{{.Version}}</code></p></main></body></html>
`
