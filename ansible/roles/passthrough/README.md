# passthrough

The node that carries a card a VM owns — runs **on the Proxmox node** (become
root). The node never drives the card:

1. `vfio-pci` claims every function at boot (`/etc/modprobe.d`), the host
   drivers are blacklisted, the modules load early (`modules-load.d`, the
   initramfs is rebuilt, every ESP refreshed through `proxmox-boot-tool`).
2. The kernel command line gets `iommu=pt initcall_blacklist=sysfb_init` as a
   GRUB drop-in (`/etc/default/grub.d/`) — the card that POSTed the box keeps
   no firmware framebuffer, so vfio can take it. **The node's own screen goes
   dark once the kernel runs**; firmware, GRUB and MokManager still show.
3. `vendor_reset: true` → [gnif/vendor-reset](https://github.com/gnif/vendor-reset)
   through DKMS for every kernel with headers, its udev rule (`reset_method`
   → `device_specific`). Under Secure Boot DKMS signs the module with its own
   MOK key; the role queues the enrolment (`mokutil --import --root-pw`):
   **at the next boot MokManager asks — Enroll MOK → Continue → Yes → the
   root password.**
4. The cluster PCI mapping (`pvesh create /cluster/mapping/pci`) from the
   ids read **live** (vendor:device, subsystem, IOMMU group of function 0,
   every function by `path`), checked by the cluster itself
   (`--check-node`).
5. `use_by` → `PVEMappingUser` on `/mapping/pci/<id>` for the provisioning
   identity (tofu's token) — it may use **this** mapping, nothing wider.

A reboot is reported (`REBOOT DUE`), never performed. Idempotent: the
second run after the reboot prints `Verified`. Contract:
[`defaults/main.yml`](defaults/main.yml).

```yaml
arcade_passthrough_devices:
  - { id: rx5700xt, node: muscle1, path: "0000:09:00", vendor_reset: true, use_by: [automation@pve],
      description: "RX 5700 XT (Navi 10) + its HDMI audio" }
```
