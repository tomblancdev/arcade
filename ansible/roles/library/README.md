# library

The ROM store's local copy: `arcade-roms-sync.service` (oneshot, every boot)
rsyncs the read-only NFS mount to the local NVMe cache, owned by the player's
user; `ConditionPathIsMountPoint` skips it when the server is down — the last
copy keeps playing, nothing is ever synced from an empty mount point.
Contract: [`defaults/main.yml`](defaults/main.yml).
