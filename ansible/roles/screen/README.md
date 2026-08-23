# screen

The GPU-owner VM after its install runbook (Bazzite = Fedora Atomic, bootc):
the automation lane (the admin user in wheel, sudo without a password, its
password locked, sshd keys-only/no root), the static address kept by
NetworkManager (born at the install), the data mounts — NFSv4, soft on
purpose, one mount per service under `/srv` — `nfs-utils` layered if the
image lacks it, the idle watchdog (`arcade-idle`: no stream, no couch input,
no admin shell for N min → `poweroff`), and Grafana Alloy as a Quadlet
(`arcade-alloy`: journald incl. user units + node metrics with the card's
hwmon → the aggregator).

**The runbook before the first run** (once, at the screen): install the
image from the ISO with the static address typed in the installer, then in a
terminal: `sudo useradd -m -G wheel ansible && sudo passwd ansible && echo
'ansible ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ansible && sudo
systemctl enable --now sshd`; from the workstation `ssh-copy-id
ansible@<address>` — the role locks the password and turns password logins
off at its first run. Contract: [`defaults/main.yml`](defaults/main.yml).
