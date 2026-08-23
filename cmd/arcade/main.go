// L'Arcade — the doorman of a home games platform: knock to wake, the play
// page, the Moonlight relay for the internet, the pairing-PIN relay.
//
// v0.1 (G0): the skeleton — /healthz, /metrics and a placeholder page, so the
// image, the pin and the rows exist before the doorman's own session (G2).
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
	_ "time/tzdata"

	"github.com/tomblancdev/arcade/internal/web"
)

// set by -ldflags "-X main.version=..."
var version = "dev"

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil)).With("service", "arcade")
	slog.SetDefault(logger)

	listen := os.Getenv("ARCADE_LISTEN")
	if listen == "" {
		listen = ":8080"
	}

	srv := web.New(version, logger)

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	hs := &http.Server{Addr: listen, Handler: srv.Handler(), ReadHeaderTimeout: 10 * time.Second}
	go func() {
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_ = hs.Shutdown(shutdown)
	}()
	logger.Info("listening", "addr", listen, "version", version)
	if err := hs.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		logger.Error("http", "err", err)
		os.Exit(1)
	}
	logger.Info("bye")
}
