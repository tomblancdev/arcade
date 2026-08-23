<p align="center"><img src="ui/static/logo-animated.svg" alt="Le Squat — l'arcade // insert coin" width="640"></p>

# L'Arcade

**A home games platform as bricks, not a box.** One VM owns the GPU and is
*the screen* (Bazzite: the couch on HDMI, Sunshine for every other screen);
emulation and stores run inside it; dedicated game servers are one container
each in a small VM; a 24/7 **doorman** wakes the whole thing on a knock, shows
the play page and relays Moonlight to friends outside. A project — the
console, a Minecraft server, a remote desktop for a relative — *picks bricks*
and is a few lines of data.

Built for [Le Squat](https://github.com/tomblancdev/le-squat), a three-node
Proxmox home lab whose gaming node sleeps most of the day. The lab holds the
**data** (addresses, datasets, firewall rows, identities, secrets); this repo
holds the **platform** — and stays usable by anyone with a Proxmox box and a
GPU:

| Part | What | Where |
|---|---|---|
| the collection `tomblancdev.arcade` | roles `screen` · `sunshine` · `retrodeck` · `library` · `servers` · `doorman` — data in, facts out | [`ansible/`](ansible) |
| the tofu modules | `screen-vm` (the GPU owner), `servers-vm`, `doorman-ct` — bpg/proxmox | [`tofu/modules/`](tofu/modules) |
| the doorman | a Go app, one static binary, `ghcr.io/tomblancdev/arcade` — knock → wake, the play page, the Sunshine relay, the pairing-PIN relay, metrics | [`cmd/arcade`](cmd/arcade), [`deploy/quadlet`](deploy/quadlet) |

## How it is meant to work

```
friend's Moonlight ──(a lease from Le Videur)──▶ doorman ──relay──▶ console VM (Sunshine, channels = one pad each)
house TV / phone ───────────────────────────────────────────────▶ console VM (LAN)
        a knock anywhere ──▶ doorman ──ssh, one forced command──▶ hypervisor: wake · start 5001 · stop · status
        20 min idle ──▶ the VM stops itself ──▶ the node sleeps
```

- **One GPU owner.** The card belongs to one VM; everything that needs it
  runs inside as a service with its own mount, unit and role — never a
  second VM fighting for the card.
- **Data by nature.** The platform declares what its data *is* (saves and
  catalogue irreplaceable, the ROM store replaceable and synced to local
  NVMe at every wake); the lab's backup layer decides what that earns.
- **Public only behind one gate.** Nothing listens on the internet until the
  lab flips `games_public`; friends then get a time-boxed, audited opening
  from [Le Videur](https://github.com/tomblancdev/videur), never a port.
- **Everything expires.** Sessions, leases, the VM's uptime, the node's.

The design lives in the lab's documentation
([`docs/games.md`](https://github.com/tomblancdev/le-squat/blob/main/docs/games.md))
until it moves here with the doorman.

## Status

| Gate | What | State |
|---|---|---|
| G0 | the skeleton: collection contracts, module contracts (`screen-vm` + `doorman-ct` validated), the doorman's `/healthz` `/metrics`, CI → GHCR, the first pin | **done** |
| G1 | the console: `screen-vm` applied, roles `screen` `sunshine` `retrodeck` `library` | next |
| G2 | the doorman: knock → wake, the play page, the relay; role `doorman`, module `doorman-ct` | |
| G3 | the first dedicated server: role `servers`, module `servers-vm` | |
| G4 | the public flip: DynHost, the WAN rows, leases through Le Videur | |

## Run the doorman

```sh
podman run --rm -p 8080:8080 ghcr.io/tomblancdev/arcade:0.1.0
# http://localhost:8080 — /healthz, /metrics
```

The image is `scratch` + one binary; it runs as uid 65532 with a read-only
root. `ARCADE_LISTEN` (default `:8080`). Structured JSON logs on stdout.

## Develop

No toolchain on the host: `podman run --rm -v "$PWD":/src -w /src golang:1.24-alpine go test ./...`.
The collection: `ansible-galaxy collection build ansible/`. The modules:
`tofu -chdir=tofu/modules/screen-vm init -backend=false && tofu validate`.
Tags `v*` build and push the image; a lab pins the collection and the
modules by the same tag.

## License

MIT — Tom Blanc. The mark and the faces belong to the
[La Loge](https://github.com/tomblancdev/la-loge) family (Big Shoulders
Stencil + IBM Plex Mono, OFL, embedded).
