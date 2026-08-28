# wolf

The seat engine on a minimal host. One person = one **seat**: a container with
its own headless compositor, its own home and its own login, created when they
connect and removed when they leave — so an empty room costs nothing. The
engine spawns them itself through the container engine's socket, which is why
it effectively owns the guest it runs on; put that in your permission model
before you run it, not after.

This role carries the host side of that: the card's firmware (the cloud images
ship none), `uinput`, a rootful container socket, the seat store, and the
engine as a system unit. It installs no apps — what a person may run is a
catalogue, written into the engine's own config file just before the engine
reads it (below: why not its API).

Three things worth knowing before you change anything:

* **The paths are identical on both sides on purpose.** What the engine hands
  the seats it spawns are *host* paths. A path that exists only inside the
  container is created empty outside it, and the seat dies in a couple of
  seconds with no display and no audio and nothing in the log that explains it.
* **The seat store wants its own device.** Give it one and it becomes XFS with
  project quotas, so a person's cap is a filesystem fact. Leave
  `arcade_wolf_data_device` empty and everything still works, uncapped. A
  device that already carries a filesystem this role did not make is refused,
  never overwritten.
* **The ports are Sunshine's ports.** Same protocol, same defaults. A host
  running both must move one of them; every port here has its own environment
  variable, and the engine advertises whatever it was given.

* **The catalogue lands in the engine's config before the engine starts —
  not through its API.** The engine computes a tile's video caps only when it
  reads its config file; an app added through the API is saved to that file
  at once but lives in memory with an *empty* caps until the next start, and
  such a tile shows in Moonlight and never sends a frame (the client blames a
  firewall). So what may exist is handed in as data (`arcade_wolf_apps`,
  `arcade_wolf_apps_absent`), written to `/etc/wolf/catalogue.json`, and
  `wolf-catalogue project` rewrites the Moonlight profile's app list in
  `config.toml` as the engine's own unit starts (`ExecStartPre`) — add what
  is missing, replace what differs, remove what is named absent, leave the
  rest alone (a person's own addition is theirs), touch nothing else in the
  file, and keep the previous file whenever the rewrite reads back wrong. A
  converge pushes nothing: `wolf-catalogue diff` reads what the engine *has*,
  and a difference restarts the engine only when no session is live —
  otherwise it is deferred, said in the play and in the journal, and lands at
  the next start. A seat's ceiling travels inside its app definition as the
  container engine's own `HostConfig` (`NanoCpus`, `Memory`); an app that
  runs its own sandbox inside the seat (a Flatpak, Steam) needs the wider
  capability set — both sets are in `arcade_wolf_host_config`, for whoever
  renders the definitions. Every image the catalogue names is pulled by the
  converge, before the engine is (re)started — the first tap never waits on
  a pull, and a rebuilt host carries its tiles before anyone tries one. Present,
  never pruned: an image the catalogue does not name may be a person's own.

* **What the host lends a seat.** Read-only files under `/etc/wolf/seat/`
  that a catalogue line may mount into its seats, kept outside the people's
  homes. Today: `seat-sway-fullscreen` (+ its `.conf` for
  `/etc/sway/config.d/`) — for a launcher seat under sway, the bar hidden
  and every game window *kept* fullscreen: the image's own `for_window` rule
  fires once at map, and Wine drops the hint whenever its window is smaller
  than the screen, leaving the game tiled next to its launcher.

* **A person's state is copied, not mounted.** The seat home is local so
  that play never touches the network, whatever the app writes and however
  often; the folders an app declares as state (`arcade_wolf_state_apps`) are
  copied by `wolf-state-sync` to a mount of the person's own
  (`arcade_wolf_state_root/<profile>`) every few minutes and at every engine
  start and stop. Two copies are kept safe by one rule — a folder is never
  pushed before it has been pulled once — so a re-made disk restores itself
  and can never wipe what the mount holds. It logs `OK` per run; watch for
  its absence. One host holds a person's live state at a time.

* **A new person opens a ready app, not a wizard.** Two shapes of *golden
  template*, both seeded once and never touched again. A whole home
  (`arcade_wolf_golden_apps`): an app with no headless first run (RetroDECK)
  has one completed setup captured under `<golden_dir>/<title>` and copied
  into a seat the first time that home is empty. A **part** of a home
  (`arcade_wolf_golden_parts`): an app whose first run *is* the person's own
  (Steam: the login) still has parts that can be a template — a title's
  Proton prefix. Steam records each install-script step as done inside the
  prefix's own registry, so a step that hangs under Wine hangs once per
  drawer; a prefix captured once, with the marks and without the person
  (`wolf-golden-prefix <profile> <app> <path>`), and seeded before the
  title's first launch is a first launch that just starts — Proton keeps a
  prefix it finds. The path must be the app's *real* one: the directories
  on the way are made for the seat's uid.

Contract: [`defaults/main.yml`](defaults/main.yml).
