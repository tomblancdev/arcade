variable "node" {
  description = "Proxmox node that carries the GPU"
  type        = string
}
variable "vmid" {
  description = "VMID"
  type        = number
}
variable "name" {
  description = "VM name (its hostname is set by the screen role)"
  type        = string
  default     = "console"
}
variable "description" {
  type    = string
  default = "the screen — GPU-owner VM (Bazzite): HDMI couch + Sunshine"
}
variable "tags" {
  type    = list(string)
  default = ["games", "keep-awake"]
}
variable "cores" {
  type    = number
  default = 6
}
variable "memory" {
  description = "MiB, no ballooning (the GPU pins the guest's memory anyway)"
  type        = number
  default     = 16384
}
variable "datastore" {
  description = "datastore for the OS disk + the EFI vars (local NVMe: the Steam cache lives here)"
  type        = string
  default     = "local-zfs"
}
variable "disk" {
  description = "OS disk size, GiB"
  type        = number
  default     = 150
}
variable "gpu_mapping" {
  description = "name of the cluster PCI resource mapping for the GPU (both functions: video + HDMI audio)"
  type        = string
}
variable "bridge" {
  description = "the bridge/vnet the VM's NIC joins (a name, never a raw VLAN tag)"
  type        = string
}
variable "iso" {
  description = "file id of the install ISO (attached on ide2 for the runbook); null = no cdrom"
  type        = string
  default     = null
}
variable "agent" {
  description = "qemu-guest-agent present in the guest (Bazzite ships it)"
  type        = bool
  default     = true
}
