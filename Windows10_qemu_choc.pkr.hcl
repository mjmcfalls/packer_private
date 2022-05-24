
variable "autounattend" {
  type    = string
  default = "${env("autounattend")}"
}

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
  default = "c:/temp"
}

variable "winrm_insecure" {
  type    = string

}

variable "winrm_password" {
  type    = string
}

variable "winrm_timeout" {
  type    = string
  default = "1h"
}

variable "winrm_use_ntlm" {
  type    = string
}

variable "winrm_use_ssl" {
  type    = string
}

variable "winrm_username" {
  type    = string
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "choc_git_install" {
   type    = map(string)
}
variable "choc_vscode_install" {
  type    = map(string)
}

variable "choc_vscode_noUpdate" {
  type    = map(string)
}

variable "anyconnect_installer" {
  type    = string
  default = "${env("anyconnect_installer")}"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "qemu" "Windows_10" {
  accelerator      = "kvm"
  boot_wait        = "120s"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  disk_size        = "${var.disk_size}"
  disk_interface   = "virtio"
  floppy_files     = ["${var.autounattend}","./src/scripts/"]
  # cd_files         = ["./src/apps/VirtIO/"]
  # cd_label         = "Drivers"
  # cdrom_interface  = "ide"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  net_device       = "e1000"
  # net_bridge      = "${var.switchname}"
  output_directory = "${var.nix_output_directory}"
  shutdown_command = "${var.shutdown_command}"
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
  sources = ["source.qemu.Windows_10"]
  
  provisioner "powershell" {
    inline = ["a:/Config_Winrm.ps1"]
  }

  provisioner "file" {
    source      = "./src/scripts/"
    destination = "${var.win_temp_dir}/scripts/"
    direction   =  "upload"
  }

  provisioner "powershell"{
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:/install_pswindowsupdate.ps1",
      "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
      "Start-Process -NoNewWindow -FilePath 'C:\\ProgramData\\chocolatey\\bin\\RefreshEnv.cmd' -Wait",
      "a:/Install_windowsupdates.ps1",
      "a:/install_choc_app.ps1 -packagesPath 'a:\\packages.config'",
      "${var.win_temp_dir}\\scripts\\CiscoAnyconnect\\install_anyconnect.ps1 -Cleanup -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anyconnect_installer}' -install",
      "${var.win_temp_dir}\\scripts\\Windows10_cleanup.ps1",
      "a:\\Windows_optimize.ps1 -outpath '${var.win_temp_dir}'"
    ]
  }
}