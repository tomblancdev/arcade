# screen-vm

The GPU-owner VM: OVMF + q35, host CPU, no ballooning, the GPU through a
**cluster PCI resource mapping** as the primary display (`x-vga`, no emulated
VGA), one NIC on a named bridge with the hypervisor firewall on, an optional
install ISO on `ide2`. tofu never starts or stops it (`started` ignored):
Le Veilleur wakes it and stops it.

```hcl
module "console" {
  source      = "github.com/tomblancdev/arcade//tofu/modules/screen-vm?ref=v0.5.0"
  node        = "tower"
  vmid        = 5001
  gpu_mapping = "rx5700xt"
  bridge      = "games"
  iso         = proxmox_virtual_environment_download_file.bazzite.id   # the runbook, once
  on_boot     = false  # Le Veilleur owns the wake
}
```

The GPU reaches the guest through a cluster mapping created by the
[`passthrough`](../../../ansible/roles/passthrough) role; `gpu_mapping` names it.
