// Package ui embeds the doorman's static files (the mark, later the play page).
package ui

import "embed"

// Static is served under /static/.
//
//go:embed static
var staticFS embed.FS

// Static is the static tree rooted at "static/".
var Static = mustSub(staticFS, "static")
