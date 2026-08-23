# doorman-ct — an unprivileged Debian CT running the doorman image under
# podman Quadlet. Podman in an unprivileged CT needs nesting + keyctl: the
# provisioning token cannot write features (root@pam-only), the doorman role
# sets them via pct on the node — tofu must never reconcile them away.
resource "proxmox_virtual_environment_container" "doorman" {
  node_name     = var.node
  vm_id         = var.vmid
  description   = var.description
  tags          = var.tags
  unprivileged  = true
  start_on_boot = true
  started       = true

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.memory
  }

  lifecycle {
    ignore_changes = [features]
  }

  disk {
    datastore_id = var.datastore
    size         = var.disk
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  network_interface {
    name     = "eth0"
    bridge   = var.bridge
    firewall = true
  }

  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = var.address
        gateway = var.gateway
      }
    }
    dns {
      servers = var.dns
    }
    user_account {
      keys = var.ssh_keys
    }
  }
}
