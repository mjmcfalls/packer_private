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
  floppy_files     = ["${var.autounattend}","./src/scripts/"]
  format           = "qcow2"
  headless         = "${var.headless}"
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
  disk_image       = true
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  floppy_files     = ["./src/scripts/"]
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
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

source "hyperv-iso" "Windows10_iso" {
  boot_wait        = "120s"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${var.autounattend}","./src/scripts/"]
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
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


build {
  name = "win_iso"
  sources = ["source.qemu.Windows10_iso"]

  provisioner "powershell" {
    inline = [
      "a:/Config_Winrm.ps1",
    ]
  }
}


build { 
  name = "win_base"
  sources = ["source.qemu.Windows10_base"]

  # provisioner "file" {
  #   source      = "./src/scripts/"
  #   destination = "${var.win_temp_dir}/scripts/"
  #   direction   =  "upload"
  # }

  provisioner "powershell" {
    inline = [
      "a:/download_installers.ps1"
      "a:/Config_Winrm.ps1",
      "a:\\Virtio\\install_Virtio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -isoname '${var.virtio_isoname}' -install",
      "a:\\Install_pswindowsupdate.ps1",
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -install",
      "${var.win_temp_dir}\\scripts\\7zip\\install_7zip.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.seven_zip_installer}' -install",
      "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.chrome_installer}' -install",
      "${var.win_temp_dir}\\scripts\\git\\install_git.ps1 -OutPath '${var.win_temp_dir}' -uri '${var.git_uri}' -public -install",
      "${var.win_temp_dir}\\scripts\\VSCode\\install_vscode.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.vscode_installer}' -install",
      "${var.win_temp_dir}\\scripts\\Python\\install_python.ps1 -uri '${var.python_uri}' -OutPath '${var.win_temp_dir}' -public -install",
      "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -OutPath '${var.win_temp_dir}' -uri '${var.firefox_uri}' -public -install",
      "${var.win_temp_dir}\\scripts\\r\\install_r.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.r_installer}' -install",
      "${var.win_temp_dir}\\scripts\\rstudio\\install_r_studio.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.r_studio_install}' -install",
      "${var.win_temp_dir}\\scripts\\anaconda\\install_anaconda.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anaconda_installer}' -installParams '${var.anaconda_install_type} ${var.anaconda_install_addpath} ${var.anaconda_install_registerpy} ${var.anaconda_install_silent} ${var.anaconda_install_dir}' -install -navigatorUpdate",
      "${var.win_temp_dir}\\scripts\\atom\\install_atom.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}'  -install",
      "${var.win_temp_dir}\\scripts\\notepadplusplus\\install_notepadplusplus.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}'  -install",
      "${var.win_temp_dir}\\scripts\\winmerge\\install_winmerge.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -install",
      "${var.win_temp_dir}\\scripts\\texstudio\\install_texstudio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -install",
      "a:\\Windows_os_optimize.ps1"
    ]
  }
}

build { 
  name = "win_base_apps1"
  sources = ["source.qemu.Windows10_base"]

  provisioner "file" {
    source      = "./src/scripts/"
    destination = "${var.win_temp_dir}/scripts/"
    direction   =  "upload"
  }

# Application installations
  provisioner "powershell" {
    inline = [
      "${var.win_temp_dir}\\scripts\\Microsoft\\install_adk.ps1 -uri '${var.ms_adk_uri}' -OutPath '${var.win_temp_dir}' -installername '${var.ms_adk_installer}' -public -install"
      # "${var.win_temp_dir}\\scripts\\CiscoAnyconnect\\install_anyconnect.ps1 -Cleanup -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anyconnect_installer}' -install",
      ]
  }
}

build { 
  name = "win_base_optimize"
  sources = ["source.qemu.Windows10_base"]

  provisioner "file" {
    source      = "./src/scripts/"
    destination = "${var.win_temp_dir}/scripts/"
    direction   =  "upload"
  }

  provisioner "powershell" {
    inline = [
      "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
      ]
  }
}
