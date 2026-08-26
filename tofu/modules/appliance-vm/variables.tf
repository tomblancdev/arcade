variable "node" {
  description = "Proxmox node that carries the GPU"
  type        = string
}
variable "vmid" {
  description = "VMID"
  type        = number
}
variable "name" {
  description = "VM name (= its cloud-init hostname)"
  type        = string
}
variable "description" {
  type    = string
  default = "the appliance — a GPU-owner VM with no glass: a minimal OS, a container engine, and the seat engine on top"
}
variable "tags" {
  type    = list(string)
  default = ["games"]
}
variable "cores" {
  type    = number
  default = 10
}
variable "memory" {
  description = "MiB, no ballooning (a passed-through card pins the guest's memory anyway)"
  type        = number
  default     = 32768
}
variable "datastore" {
  description = "datastore for the disks and the cloud-init drive"
  type        = string
  default     = "local-zfs"
}
variable "image" {
  description = "file id of the cloud image imported onto scsi0 (a `content_type = import` download resource)"
  type        = string
}
variable "disk" {
  description = "OS disk size, GiB — the OS is a few GiB; this is not where the seats live"
  type        = number
  default     = 40
}
variable "data_disk" {
  description = "second disk, GiB, presented as scsi1 — the seat store. 0 = none (the engine then keeps its state on the OS disk)"
  type        = number
  default     = 0
}
variable "gpu_mapping" {
  description = "name of the cluster PCI resource mapping for the GPU (both functions: render + HDMI audio)"
  type        = string
}
variable "bridge" {
  description = "the bridge/vnet the VM's NIC joins (a name, never a raw VLAN tag)"
  type        = string
}
variable "vlan_id" {
  description = "VLAN tag, when the bridge is not already a per-VLAN vnet. null = none"
  type        = number
  default     = null
}
variable "address" {
  description = "static IPv4 in cidr form, e.g. 192.0.2.23/24 — cloud-init writes it. `dhcp` = let the network answer"
  type        = string
}
variable "gateway" {
  description = "IPv4 gateway (ignored when address = dhcp)"
  type        = string
  default     = null
}
variable "dns_servers" {
  description = "resolvers cloud-init writes"
  type        = list(string)
  default     = []
}
variable "ssh_keys" {
  description = "public keys injected for the root account — the guests' access model is key-only"
  type        = list(string)
}
variable "on_boot" {
  description = "start the VM when its node boots. KEEP THIS FALSE while another guest is defined with the same GPU mapping: the card is exclusive, and whichever one starts first takes it"
  type        = bool
  default     = false
}
variable "agent" {
  description = "qemu-guest-agent expected in the guest (the converge installs it)"
  type        = bool
  default     = true
}
