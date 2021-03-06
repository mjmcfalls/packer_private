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

variable "r_download_uri" {
  type    = string
  default = "${env("r_download_uri")}"
}

variable "r_studio_download_uri" {
  type    = string
  default = "${env("r_studio_download_uri")}"
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

variable "keep_registered" {
  type    = string
  default = "${env("keep_registered")}"
}

variable "seven_zip_installer" {
  type    = string
  default = "${env("seven_zip_installer")}"
}

variable "chrome_installer" {
  type    = string
  default = "${env("chrome_installer")}"
}

variable "seven_zip_uri" {
  type    = string
  default = "${env("seven_zip_uri")}"
}

variable "anyconnect_installer" {
  type    = string
  default = "${env("anyconnect_installer")}"
}

variable "python_uri" {
  type    = string
  default = "${env("python_uri")}"
}

variable "vscode_installer" {
  type    = string
  default = "${env("vscode_installer")}"
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

variable "ms_adk_uri" {
  type    = string
  default = "${env("ms_adk_uri")}"
}

variable "ms_adk_installer" {
  type    = string
  default = "${env("ms_adk_installer")}"
}

variable "shutdown_command" {
  type    = string
  default = "${env("shutdown_command")}"
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

# # 60+ minutes with cleanup/optimize scripts
# Manual install scripts
  # provisioner "powershell" {
  #   inline = [
  #     "a:\\Install_pswindowsupdate.ps1",
  #     "a:\\Install_windowsupdates.ps1"
  #     ]
  # }

  # provisioner "windows-restart" {}

  provisioner "powershell" {
    inline = [
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -install"
      # "${var.win_temp_dir}\\scripts\\install_7zip.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.seven_zip_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      # "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.chrome_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\VSCode\\install_vscode.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.vscode_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\Python\\install_python.ps1 -uri '${var.python_uri}' -OutPath '${var.win_temp_dir}' -public -install",
      # "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -OutPath '${var.win_temp_dir}' -uri '${var.firefox_uri}' -public -install",
      # "${var.win_temp_dir}\\scripts\\install_r.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.r_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\Get_r_studio.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.r_studio_install}' -install",
      # "${var.win_temp_dir}\\scripts\\install_anaconda.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anaconda_installer}' -installParams '${var.anaconda_install_type} ${var.anaconda_install_addpath} ${var.anaconda_install_registerpy} ${var.anaconda_install_silent} ${var.anaconda_install_dir}'-install",
      # "${var.win_temp_dir}\\scripts\\CiscoAnyconnect\\install_anyconnect.ps1 -Cleanup -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anyconnect_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\install_git.ps1 -OutPath '${var.win_temp_dir}' -uri '${var.git_uri}' -public -install",
      # "${var.win_temp_dir}\\scripts\\Microsoft\\install_adk.ps1 -uri '${var.ms_adk_uri}' -OutPath '${var.win_temp_dir}' -installername '${var.ms_adk_installer}' -public -install",
      # "${var.win_temp_dir}\\scripts\\Windows10_cleanup.ps1",
      # "a:\\Windows_optimize.ps1 -outpath '${var.win_temp_dir}'"
      ]
  }

}