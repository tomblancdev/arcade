# appliance-vm — a GPU-owner VM with NO GLASS.
#
# The sibling module `screen-vm` builds the other kind: a guest whose card
# drives a physical display, so it is the primary adapter (`x-vga`), it boots
# on the panel, and its OS is installed by hand from an ISO at that panel.
#
# This one owns a card the same way and shows it to nobody. Every consumer of
# the GPU is a container inside the guest, reaching it as a render node, and
# whatever those containers put on a wire is somebody else's problem. That one
# difference pays for itself three times over:
#
#   * no `x-vga`, so the guest keeps an ordinary emulated display and serial
#     console — which means cloud-init works, which means the VM is BORN FROM
#     CODE instead of from a keyboard in front of a screen;
#   * no display means no monitor and no EDID emulator, ever;
#   * the OS carries a kernel, its firmware and a container engine, nothing
#     else. The userspace graphics stack travels inside the images.
#
# SeaBIOS on purpose (the sibling uses OVMF): OVMF is what a card needs when it
# is the guest's primary adapter and has to post on it. A secondary card is
# initialised by the guest's own driver, so the firmware question does not
# arise — and a plain cloud image on SeaBIOS is the arrangement this lab
# already runs elsewhere.
#
# THE CARD IS EXCLUSIVE. Several guests may be DEFINED against one PCI
# resource mapping; only one of them may RUN. That is the property this module
# is meant to be used with: define the replacement beside the incumbent, start
# whichever you are working on, and the rollback is `stop` one, `start` the
# other. It is also why `on_boot` defaults to false — a node that reboots on
# its own must not decide which of them wins.
resource "proxmox_virtual_environment_vm" "appliance" {
  node_name   = var.node
  vm_id       = var.vmid
  name        = var.name
  description = var.description
  tags        = var.tags
  on_boot     = var.on_boot
  started     = false # birth only; who starts this is the operator's business (a watchman, a panel, a hand)

  machine             = "q35"
  scsi_hardware       = "virtio-scsi-single"
  boot_order          = ["scsi0"]
  reboot_after_update = false

  cpu {
    cores = var.cores
    type  = "host" # the containers want the real CPU, and the card pins this guest to one node anyway
  }

  memory {
    dedicated = var.memory
    floating  = 0 # no ballooning: a passed-through card pins the guest's memory
  }

  # the OS disk: the cloud image imported straight in (PVE 9 `import` content)
  disk {
    datastore_id = var.datastore
    import_from  = var.image
    interface    = "scsi0"
    size         = var.disk
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  # the second disk: where per-user state lives. Its own disk on purpose — a
  # filesystem of its own is what makes per-directory quotas and a rebuild of
  # the OS independent of each other.
  dynamic "disk" {
    for_each = var.data_disk > 0 ? [var.data_disk] : []
    content {
      datastore_id = var.datastore
      interface    = "scsi1"
      size         = disk.value
      discard      = "on"
      ssd          = true
      iothread     = true
    }
  }

  # the card: a cluster resource mapping (both functions — the audio function
  # travels with the video one whether or not anything listens to it).
  # x-vga is DELIBERATELY absent: this guest has no glass, so the card is a
  # render node and the emulated adapter below stays the display.
  hostpci {
    device  = "hostpci0"
    mapping = var.gpu_mapping
    pcie    = true
    rombar  = true
  }

  # kept, unlike the sibling: a console to open when the network is the thing
  # that broke. Costs nothing and is the difference between a fix and a drive.
  vga {
    type = "std"
  }

  serial_device {
    device = "socket"
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_id
    firewall = true # the hypervisor firewall filters this NIC (east-west)
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = var.agent
    timeout = "2m" # the agent lands with the first converge; until then the provider waits this long for an address
    trim    = true
  }

  initialization {
    datastore_id = var.datastore

    ip_config {
      ipv4 {
        address = var.address
        gateway = var.address == "dhcp" ? null : var.gateway
      }
    }

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [var.dns_servers] : []
      content {
        servers = dns.value
      }
    }

    user_account {
      username = "root" # the guests' access model: root by injected key, nothing else
      keys     = var.ssh_keys
    }
  }

  # `started = false` above is a BIRTH fact, not a policy: who runs this guest
  # is the operator's business (a watchman, a panel, a hand), and a plan that
  # offers to stop a machine somebody is playing on is a plan that will one day
  # be applied by accident. Same for `import_from`: it names a downloaded image
  # the disk stops resembling the moment the guest boots. Only the OS disk is
  # pinned — a change to the SEAT disk is a real change and must show in a plan.
  lifecycle {
    ignore_changes = [started, disk[0]]
  }
}
