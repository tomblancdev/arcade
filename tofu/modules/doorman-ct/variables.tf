variable "node" {
  description = "a 24/7 node — the doorman answers while the console sleeps"
  type        = string
}
variable "vmid" {
  type = number
}
variable "hostname" {
  type    = string
  default = "arcade"
}
variable "description" {
  type    = string
  default = "L'Arcade — the doorman: knock→wake, the play page, the Moonlight relay"
}
variable "tags" {
  type    = list(string)
  default = ["games"]
}
variable "template_file_id" {
  description = "the CT template (Debian), e.g. local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
  type        = string
}
variable "address" {
  description = "static IPv4 with prefix, e.g. 10.10.50.20/24"
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
  description = "public keys injected for root (the lab's automation key)"
  type        = list(string)
}
variable "cores" {
  type    = number
  default = 1
}
variable "memory" {
  type    = number
  default = 512
}
variable "disk" {
  type    = number
  default = 4
}
variable "datastore" {
  type    = string
  default = "local-zfs"
}
