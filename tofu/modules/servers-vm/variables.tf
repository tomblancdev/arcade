variable "node" {
  type = string
}
variable "vmid" {
  type = number
}
variable "name" {
  type    = string
  default = "servers"
}
variable "cloud_image_file_id" {
  description = "a Debian generic cloud image imported on the node (cloud-init)"
  type        = string
}
variable "address" {
  description = "static IPv4 with prefix"
  type        = string
}
variable "gateway" {
  type = string
}
variable "dns" {
  type = list(string)
}
variable "bridge" {
  type = string
}
variable "ssh_keys" {
  type = list(string)
}
variable "cores" {
  type    = number
  default = 4
}
variable "memory" {
  type    = number
  default = 12288
}
variable "disk" {
  type    = number
  default = 60
}
variable "datastore" {
  type    = string
  default = "local-zfs"
}
