# retrodeck

The emulation front: the RetroDECK Flatpak (system, Flathub). Its home is
**local NVMe** (a RetroDECK home is ~50k small files — cores, configs,
shaders; on NFS every op is a network round-trip). Only the irreplaceable,
hand-made state is symlinked to the **tank, live** (`arcade_retrodeck_state`):
`saves`, `states`, `screenshots`, and ES-DE `gamelists` (the catalogue — play
counts, favourites, custom names); the regenerable bulk stays local. `roms` →
the library's local copy. First run: launch RetroDECK, pick the
**Internal/default** location, then converge to symlink the state. Contract:
[`defaults/main.yml`](defaults/main.yml).
