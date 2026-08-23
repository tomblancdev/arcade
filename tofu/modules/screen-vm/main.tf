# screen-vm — the GPU-owner VM. The appliance OS (Bazzite) is installed by
# hand from the ISO, once; everything after is the `screen` role. The VM is
# never force-started or stopped by tofu (the doorman and the idle timer own
# that): `started` is ignored after creation.
resource "proxmox_virtual_environment_vm" "screen" {
  node_name   = var.node
  vm_id       = var.vmid
  name        = var.name
  description = var.description
  tags        = var.tags
  on_boot     = var.on_boot # false once a doorman owns the wake (the node wakes for backups too); true = one WoL, the console is up
  started     = false

  bios    = "ovmf"
  machine = "q35"

  cpu {
    cores = var.cores
    type  = "host" # games want the real CPU; the VM is pinned to the GPU's node anyway
  }

  memory {
    dedicated = var.memory
    floating  = 0
  }

  efi_disk {
    datastore_id      = var.datastore
    type              = "4m"
    pre_enrolled_keys = false # Bazzite signs nothing for our platform keys; Secure Boot off in the guest
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = var.iso == null ? ["scsi0"] : ["scsi0", "ide2"]

  disk {
    datastore_id = var.datastore
    interface    = "scsi0"
    size         = var.disk
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  dynamic "cdrom" {
    for_each = var.iso == null ? [] : [var.iso]
    content {
      file_id   = cdrom.value
      interface = "ide2"
    }
  }

  # the GPU: a cluster resource mapping (both functions), the guest's primary
  # display (x-vga) — the HDMI couch boots on it; no emulated VGA at all
  hostpci {
    device  = "hostpci0"
    mapping = var.gpu_mapping
    pcie    = true
    rombar  = true
    xvga    = true
  }

  vga {
    type = "none"
  }

  network_device {
    bridge   = var.bridge
    firewall = true # the hypervisor firewall filters this NIC (east-west)
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = var.agent
  }

  lifecycle {
    ignore_changes = [started]
  }
}
