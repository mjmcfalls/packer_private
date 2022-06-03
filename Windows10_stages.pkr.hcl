variable "autounattend" {
  type    = string
  default = "${env("autounattend")}"
}

variable "anaconda_install_type" {
  type    = string
  default = "${env("anaconda_install_type")}"
}

variable "anaconda_install_addpath" {
  type    = string
  default = "${env("anaconda_install_addpath")}"
}

variable "anaconda_install_registerpy" {
  type    = string
  default = "${env("anaconda_install_registerpy")}"
}

variable "anaconda_install_silent" {
  type    = string
  default = "${env("anaconda_install_silent")}"
}

variable "anaconda_install_dir" {
  type    = string
  default = "${env("anaconda_install_dir")}"
}
variable "anaconda_installer" {
  type    = string
  default = "${env("anaconda_installer")}"
}

variable "anyconnect_installer" {
  type    = string
  default = "${env("anyconnect_installer")}"
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

variable "chrome_installer" {
  type    = string
  default = "${env("chrome_installer")}"
}

variable "firefox_uri" {
  type    = string
  default = "${env("firefox_uri")}"
}

variable "git_installer" {
  type    = string
  default = "${env("git_installer")}"
}

variable "git_uri" {
  type    = string
  default = "${env("git_uri")}"
}

variable "headless" {
  type    = string
   default = "${env("headless")}"
}

variable "http_directory"{
  type    = string
  default = "${env("http_directory")}"
}

variable "iso_checksum" {
  type    = string
  default = "${env("iso_checksum")}"
}

variable "iso_url" {
  type    = string
  default = "${env("iso_url")}"
}
variable "keep_registered" {
  type    = string
  default = "${env("keep_registered")}"
}

variable "memory" {
  type    = string
  default = "${env("memory")}"
}

variable "ms_adk_uri" {
  type    = string
  default = "${env("ms_adk_uri")}"
}

variable "ms_adk_installer" {
  type    = string
  default = "${env("ms_adk_installer")}"
}

variable "nix_output_directory" {
  type    = string
  default = "${env("nix_output_directory")}"
}

variable "nix_choco_output_directory" {
  type    = string
}

variable "npp_uri" {
  type    = string
}

variable "python_uri" {
  type    = string
  default = "${env("python_uri")}"
}

variable "seven_zip_installer" {
  type    = string
  default = "${env("seven_zip_installer")}"
}

variable "seven_zip_uri" {
  type    = string
  default = "${env("seven_zip_uri")}"
}

variable "shutdown_command" {
  type    = string
  default = "${env("shutdown_command")}"
}

variable "switchname" {
  type    = string
  default = "${env("switchname")}"
}

variable "r_download_uri" {
  type    = string
  default = "${env("r_download_uri")}"
}

variable "r_studio_download_uri" {
  type    = string
  default = "${env("r_studio_download_uri")}"
}
variable "r_install_path" {
  type    = string
  default = "${env("r_src_path")}/${env("r_version")}"
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

variable "virtio_uri" {
  type    = string
  default = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
}

variable "virtio_isoname" {
  type    = string
}

variable "vscode_installer" {
  type    = string
  default = "${env("vscode_installer")}"
}

variable "vm_name" {
  type    = string
  default = "${env("vm_name")}"
}
variable "vm_choco_name" {
  type    = string
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



packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source = "github.com/rgl/windows-update"
    }
  }
}
# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "qemu" "Windows10_iso" {
  accelerator      = "kvm"
  boot_wait        = "120s"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  disk_size        = "${var.disk_size}"
  disk_interface   = "virtio"
  floppy_files     = ["${var.autounattend}"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  net_device       = "e1000"
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

source "qemu" "Windows10_base" {
  accelerator      = "kvm"
  boot_wait        = "120s"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  disk_size        = "${var.disk_size}"
  disk_interface   = "virtio"
  floppy_files     = ["./src/scripts/"]
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  net_device       = "e1000"
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

source "qemu" "Windows10_choco" {
  accelerator      = "kvm"
  boot_wait        = "120s"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  disk_size        = "${var.disk_size}"
  disk_interface   = "virtio"
  floppy_files     = ["${var.autounattend}","./src/scripts/"]
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  net_device       = "e1000"
  output_directory = "${var.nix_choco_output_directory}"
  shutdown_command = "${var.shutdown_command}"
  vm_name          = "${var.vm_choco_name}"
  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"
}


build {
  name = "build_win_iso"
  sources = ["source.qemu.Windows_10_iso"]
}


build { 
  name = "build_win_base"
  sources = ["source.qemu.Windows_10_base"]

  provisioner "powershell" {
    inline = ["a:/Config_Winrm.ps1"]
  }

  provisioner "file" {
    source      = "./src/scripts/"
    destination = "${var.win_temp_dir}/scripts/"
    direction   =  "upload"
  }

# Drivers and other potential preqs
  provisioner "powershell" {
    inline = [
      "${var.win_temp_dir}\\scripts\\Virtio\\install_Virtio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -isoname '${var.virtio_isoname}' -install",
      "a:\\Install_pswindowsupdate.ps1"
      "a:\\Windows_os_optimize.ps1",
    ]
  }
}
