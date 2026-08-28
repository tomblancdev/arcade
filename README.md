<p align="center"><img src="ui/static/logo-animated.svg" alt="l'arcade — insert coin" width="640"></p>

# L'Arcade

**A home games platform as bricks, not a box.** One VM owns the GPU and is
*the screen* (Bazzite: the couch on HDMI, Sunshine for every other screen);
emulation and stores run inside it; dedicated game servers are one container
each in a small VM; a 24/7 panel ([Dejarik](https://github.com/tomblancdev/dejarik))
is where a person presses play, and the wake itself belongs to
[Le Veilleur](https://github.com/tomblancdev/veilleur). A project — the
console, a Minecraft server, a remote desktop for a relative — *picks bricks*
and is a few lines of data.

It was built against a three-node Proxmox home lab whose gaming node sleeps
most of the day. That deployment holds the **data** (addresses, datasets,
firewall rows, identities, secrets); this repo holds the **platform** — and
stays usable by anyone with a Proxmox box and a GPU:

| Part | What | Where |
|---|---|---|
| the collection `tomblancdev.arcade` | roles `passthrough` · `screen` · `sunshine` · `retrodeck` · `library` · `servers` — data in, facts out | [`ansible/`](ansible) |
| the tofu modules | `screen-vm` (the GPU owner), `servers-vm` — bpg/proxmox | [`tofu/modules/`](tofu/modules) |

**This repo is the platform, not the apps.** The panel a person opens to
play is its own product — [Dejarik](https://github.com/tomblancdev/dejarik)
— and the wake/sleep decision is another,
[Le Veilleur](https://github.com/tomblancdev/veilleur). What lives here is
what *builds and converges the machines*: no Go, no image, no runtime.

## How it is meant to work

```
house TV / phone ──Moonlight──▶ console VM (Sunshine, channels = one pad each)

a person ──▶ Dejarik (the panel) ──▶ Le Veilleur ──▶ wake the node, start the VM
                                 └──▶ Sunshine: can I play? · pair this PIN
nobody streaming ──▶ Le Veilleur stops the VM, then sleeps the node
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

The design lives in the documentation of whatever deployment consumes this
platform — the bricks below are the contract between the two.

## Status

| Gate | What | State |
|---|---|---|
| G0 | the skeleton: collection and module contracts, CI, the first pin | **done** |
| G1 | the console: `screen-vm` applied, roles `passthrough` `screen` `sunshine` `retrodeck` `library` | **done** |
| G2 | the panel — which grew a roadmap of its own and left: [Dejarik](https://github.com/tomblancdev/dejarik). The `doorman` role and the `doorman-ct` module were contracts for an app that now lives elsewhere, and were removed in `v0.4.0` | **done, elsewhere** |
| G3 | the first dedicated server: role `servers`, module `servers-vm` | next |
| G4 | the public flip: DynHost, the WAN rows, leases through Le Videur | |
| G5 | the seats: module `appliance-vm` and role `wolf` (the engine on a minimal host, a quota'd seat store, the catalogue written into the engine's config before it starts, its images pulled at converge; one drawer per person with its own uid, and the engine's API lent to one host through a socket-activated bridge so a panel can pair a device and point it at a drawer); the RetroDECK seat image is its own product — [La Borne](https://github.com/tomblancdev/borne) | **rungs 2–3 + identity done** |

## Develop

No toolchain on the host: `podman run --rm -v "$PWD":/src -w /src golang:1.24-alpine go test ./...`.
The collection: `ansible-galaxy collection build ansible/`. The modules:
`tofu -chdir=tofu/modules/screen-vm init -backend=false && tofu validate`.
Tags `v*` build and push the image; a lab pins the collection and the
modules by the same tag.

## This repo carries no environment

Addresses, hostnames, domains, VLAN and group names and the house word belong
to whoever runs it; the only thing crossing between a deployment and this repo
is a pinned tag. Examples and role defaults use the documentation reserves —
`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` (RFC 5737), `example.com`
(RFC 2606) — so nothing here describes a real network, and the mark ships
carrying the platform's own name. `sh tools/no-environment.sh` enforces it,
and CI runs it before anything else builds.

## License

MIT — Tom Blanc. The mark and the faces belong to the
[La Loge](https://github.com/tomblancdev/la-loge) family (Big Shoulders
Stencil + IBM Plex Mono, OFL, embedded).
