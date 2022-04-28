# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "autounattend" {
  type    = string
  default = "${env("autounattend")}"
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
  default = "false"
}

variable "hyperv_switchname" {
  type    = string
  default = "${env("hyperv_switchname")}"
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

variable "output_directory" {
  type    = string
  default = "${env("output_directory")}"
}

variable "r_install_path" {
  type    = string
  default = "${env("r_src_path")}/${env("r_installer")}"
}

variable "r_installer" {
  type    = string
  default = "${env("r_installer")}"
}

variable "r_src_path" {
  type    = string
  default = "${env("r_src_path")}"
}

variable "r_studio_install" {
  type    = string
  default = "${env("r_studio_install")}"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vm_name" {
  type    = string
  default = "${env("vm_name")}"
}

variable "vmx_version" {
  type    = string
  default = "14"
}

variable "win_temp_dir" {
  type    = string
  default = "${env("win_temp_dir")}"
}

variable "winrm_insecure" {
  type    = string
  default = "${env("winrm_insecure")}"
}

variable "winrm_password" {
  type    = string
  default = "${env("winrm_password")}"
}

variable "winrm_timeout" {
  type    = string
  default = "${env("winrm_timeout")}"
}

variable "winrm_use_ntlm" {
  type    = string
  default = "${env("winrm_use_ntlm")}"
}

variable "winrm_use_ssl" {
  type    = string
  default = "${env("winrm_use_ssl")}"
}

variable "winrm_username" {
  type    = string
  default = "${env("winrm_username")}"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "autogenerated_1" {
  boot_wait        = "0s"
  communicator     = "winrm"
  cpus             = 2
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${var.autounattend}", "./scripts/ConfigureRemotingForAnsible.ps1", "./scripts/SetLocalAccountTokenFilterPolicy.ps1", "./scripts/setup_restart.bat", "./scripts/SetupComplete.cmd"]
  headless         = true
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  output_directory = "${var.output_directory}"
  shutdown_command = "a:/setup_restart.bat"
  switch_name      = "${var.hyperv_switchname}"
  vm_name          = "${var.vm_name}"
  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.hyperv-iso.autogenerated_1"]
  provisioner "powershell" {
    inline = ["New-Item -Path c:\\Temp -ItemType directory"]
  }
  provisioner "file" {
    destination = "c:/temp/${var.r_installer}"
    source      = "${var.r_src_path}/${var.r_installer}"
  }

  provisioner "powershell" {
    inline = ["&c:\\temp\\${var.r_installer} /verysilent"]
  }

}
