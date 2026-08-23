# screen-vm

The GPU-owner VM: OVMF + q35, host CPU, no ballooning, the GPU through a
**cluster PCI resource mapping** as the primary display (`x-vga`, no emulated
VGA), one NIC on a named bridge with the hypervisor firewall on, an optional
install ISO on `ide2`. tofu never starts or stops it (`started` ignored):
the doorman wakes it, the idle timer stops it.

```hcl
module "console" {
  source      = "github.com/tomblancdev/arcade//tofu/modules/screen-vm?ref=v0.1.0"
  node        = "muscle1"
  vmid        = 5001
  gpu_mapping = "rx5700xt"
  bridge      = "games"
  iso         = proxmox_virtual_environment_download_file.bazzite.id   # the runbook, once
}
```

**Lands at G1** (validated in CI; first applied with the console).
