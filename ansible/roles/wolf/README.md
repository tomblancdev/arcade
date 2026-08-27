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
catalogue, projected through the engine's own API, because the engine
re-serialises its config file itself and a templated one would not survive.

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

* **The catalogue is projected, never templated.** The engine rewrites its
  own config file, so what may exist is handed in as data
  (`arcade_wolf_apps`, `arcade_wolf_apps_absent`), written to
  `/etc/wolf/catalogue.json`, and a oneshot unit projects it through the
  engine's API every time the engine starts — add what is missing, replace
  what differs, remove what is named absent, and leave the rest alone, because
  an app a person added is theirs. A seat's ceiling travels inside its app
  definition as the container engine's own `HostConfig` (`NanoCpus`,
  `Memory`); an app that runs its own sandbox inside the seat (a Flatpak,
  Steam) needs the wider capability set — both sets are in
  `arcade_wolf_host_config`, for whoever renders the definitions.

Contract: [`defaults/main.yml`](defaults/main.yml).
