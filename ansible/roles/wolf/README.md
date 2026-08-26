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

Contract: [`defaults/main.yml`](defaults/main.yml).
