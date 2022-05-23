# RHEL 8 FOR QEMU/KVM

variable "cpu_num" {
  type    = string
  default = "${env("cpus")}"
}

variable "disk_size" {
  type    = string
  default = "${env("disk_size")}"
}

variable "disk_type_id" {
  type    = string
  default = "${env("disk_type_id")}"
}

variable "headless" {
  type    = string
  default = "${env("headless")}"
}

variable "http_directory"{
  type    = string
  default = "${env("http_directory")}"
}

variable "switchname" {
  type    = string
  default = "${env("switchname")}"
}

variable "iso_checksum" {
  type    = string
  default = "${env("iso_checksum")}"
}

variable "iso_url" {
  type    = string
  default = "${env("iso_url")}"
}

variable "memory" {
  type    = string
  default = "${env("memory")}"
}

variable "nix_output_directory" {
  type    = string
  default = "${env("nix_output_directory")}"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vm_name" {
  type    = string
  default = "${env("vm_name")}"
}

variable "kickstartFile" {
  type    = string
  default = "${env("kickstartFile")}"
}

variable "keep_registered" {
  type    = string
  default = "${env("keep_registered")}"
}

variable "shutdown_command" {
  type    = string
  default = "${env("shutdown_command")}"
}

variable "ssh_username" {
  type    = string
  default = "${env("ssh_username")}"
}

variable "ssh_password" {
  type    = string
  default = "${env("ssh_password")}"
}
# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "qemu" "rhel_8" {
  accelerator      = "kvm"
  boot_wait        = "10s"
  communicator     = "ssh"
  cpus             = "${var.cpu_num}"
  disk_size        = "${var.disk_size}"
  disk_interface   = "virtio"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  net_device        = "virtio-net"
  output_directory = "${var.nix_output_directory}"
  shutdown_command = "${var.shutdown_command}"
  ssh_username     = "${var.ssh_username}"
  ssh_password     = "${var.ssh_password}"
  vm_name          = "${var.vm_name}"
  boot_command     = [
                        "<up><wait><tab><wait> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${ var.kickstartFile }<enter><wait5>"
                      ]
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build

build {
  sources = ["source.qemu.rhel_8"]
}