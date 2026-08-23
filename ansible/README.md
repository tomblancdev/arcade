# tomblancdev.arcade — the collection

The platform's roles. **Data in, facts out**: a lab describes its projects
in one file (`games.yml`, the shape below) and hands the relevant part to
each role; the roles never carry an address, a dataset name or a secret.

| Role | Brick | Runs on | Lands at |
|---|---|---|---|
| `screen` | the GPU-owner VM after its appliance install (Bazzite): user, static address, the mounts (live NFS + sync-at-wake), the idle → poweroff timer, the log shipper | the `console` VM | G1 |
| `sunshine` | the stream: Sunshine's ports, `channels` (one controller = one person), the apps list, pairing | inside `screen` | G1 |
| `retrodeck` | the emulation front: the RetroDECK Flatpak, its home on the live mount, ROMs from the library | inside `screen` | G1 |
| `library` | the ROM store on the VM: the NFS mount + the rsync to local NVMe at every wake (the VM plays from the copy) | inside `screen` | G1 |
| `servers` | one podman Quadlet per dedicated game server (`kind: server` projects), limits, worlds export | the `servers` VM | G3 |
| `doorman` | the doorman app (this repo's image) as a podman Quadlet: config, data dir, the one ssh key for wake/start/stop | the `arcade` CT | G2 |

Every role's `defaults/main.yml` is its contract: the variables a lab sets,
with their defaults. `tasks/main.yml` is empty until the role's gate — the
collection installs and pins from day one, the roles fill in order.

## The data a lab holds (illustrative)

```yaml
games_public: false                 # the single gate for every public door
games_ports:
  sunshine:       { tcp: [47984, 47989, 48010], udp: ["47998-48000"] }
  sunshine_admin: { tcp: [47990] }
arcade_projects:
  console:
    kind: screen
    vmid: 5001
    address: 10.10.50.21
    size: { cores: 6, memory: 16384, disk: 150 }
    idle_minutes: 20
    sunshine: { channels: 4 }
    mounts:
      - { dataset: games/console, path: /srv/screen/retrodeck, mode: live }
      - { dataset: games/roms,    path: /srv/roms,             mode: sync-at-wake }
    doors: [house, tailnet]
```

The firewall rows, the datasets and the identities stay in the lab's own
repo — this collection only consumes the parts it is handed.

## Install

```yaml
# requirements.yml
collections:
  - name: https://github.com/tomblancdev/arcade.git#/ansible/
    type: git
    version: v0.1.0
```

```sh
ansible-galaxy collection install -r requirements.yml
```
