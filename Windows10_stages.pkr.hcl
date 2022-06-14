variable "autounattend" {
  type    = string
  default = "${env("autounattend")}"
}

variable "cpu_num" {
  type    = string
  default = "4"
}

variable "disk_size" {
  type    = string
  default = "80000"
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
  default = "false"
}

variable "memory" {
  type    = string
  default = "4192"
}

variable "nix_output_directory" {
  type    = string
  default = "${env("nix_output_directory")}"
}

variable "output_directory" {
  type    = string
}

variable "shutdown_command" {
  type    = string
  default = "${env("shutdown_command")}"
}

variable "switchname" {
  type    = string
  default = "${env("switchname")}"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
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

variable "use_backing_file" {
  type    = string
  default = false
}
variable "clone_from_vmcx_path" {
  type    = string
  default = ""
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
  boot_wait        = "60s"
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
  boot_wait        = "60s"
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
  use_backing_file = "${var.use_backing_file}"
  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"
}

source "qemu" "Windows10_choco" {
  accelerator      = "kvm"
  boot_wait        = "60s"
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

source "hyperv-iso" "vm" {
  boot_wait        = "60s"
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
  switch_name      = "${var.switchname}"
  vm_name          = "${var.vm_name}"
  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"
}

source "hyperv-vmcx" "Windows_base" {
  boot_wait        = "60s"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  floppy_files     = ["./src/scripts/"]
  headless         = "${var.headless}"
  http_directory   = "${var.http_directory}"
  memory           = "${var.memory}"
  output_directory = "${var.output_directory}"
  shutdown_command = "${var.shutdown_command}"
  switch_name      = "${var.switchname}"
  vm_name          = "${var.vm_name}"
  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"
  clone_from_vmcx_path = "${var.clone_from_vmcx_path}"
}

build {
  name = "win_iso"
  sources = ["source.qemu.Windows10_iso"]

  provisioner "powershell" {
    inline = [
      "a:/Config_Winrm.ps1",
      "a:\\Windows_os_optimize.ps1"
    ]
  }
}

build {
  name = "win_iso"
  sources = ["source.hyperv-iso.vm"]

  provisioner "powershell" {
    inline = [
      "a:/Config_Winrm.ps1",
      "a:\\Windows_os_optimize.ps1 -defaultsUserSettingsPath 'a:\\DefaultUsersSettings.txt' -ScheduledTasksListPath 'a:\\ScheduledTasks.txt' -automaticTracingFilePath 'a:\\AutomaticTracers.txt' -servicesToDisablePath 'a:\\ServicesToDisable.txt'"
    ]
  }
}

build { 
  name = "win_base"
  sources = ["source.qemu.Windows10_base","source.hyperv-vmcx.Windows_base"]

  provisioner "file" {
    source      = "./src/apps/wget"
    destination = "${var.win_temp_dir}/"
    direction   =  "upload"
  }

  provisioner "powershell" {
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:/download_installers.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -wgetPath '${var.win_temp_dir}\\wget\\wget.exe'",
      # "a:\\psappdeploy\\Virtio\\install_Virtio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -isoname '${var.virtio_isoname}' -install",
      "a:\\Install_pswindowsupdate.ps1",
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -SearchPath '${var.win_temp_dir}\\apps' -app 'sysinternals'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '7zip' -installParams '/S' -installername '7z2107-x64.exe'",
      # "${var.win_temp_dir}\\scripts\\7zip\\install_7zip.ps1 -SearchPath '${var.win_temp_dir}\\apps' -installername '7z2107-x64.exe' -app '7zip'",
      # "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      # "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.chrome_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\git\\install_git.ps1 -OutPath '${var.win_temp_dir}' -uri '${var.git_uri}' -public -install",
      # "${var.win_temp_dir}\\scripts\\VSCode\\install_vscode.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.vscode_installer}' -install",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'VSCode' -installParams '/silent /loadinf=vscode.inf' -installername 'VSCodeSetup-x64-1.67.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Python2.7' -installParams '/quiet' -installername 'python-2.7.18.amd64.msi'",
      # "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -OutPath '${var.win_temp_dir}' -uri '${var.firefox_uri}' -public -install",
      # "${var.win_temp_dir}\\scripts\\r\\install_r.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.r_installer}' -install",
      # "${var.win_temp_dir}\\scripts\\rstudio\\install_r_studio.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.r_studio_install}' -install",
      # "${var.win_temp_dir}\\scripts\\anaconda\\install_anaconda.ps1 -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anaconda_installer}' -installParams '${var.anaconda_install_type} ${var.anaconda_install_addpath} ${var.anaconda_install_registerpy} ${var.anaconda_install_silent} ${var.anaconda_install_dir}' -install -navigatorUpdate",
      # "${var.win_temp_dir}\\scripts\\atom\\install_atom.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}'  -install",
      # "${var.win_temp_dir}\\scripts\\notepadplusplus\\install_notepadplusplus.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}'  -install",
      # "${var.win_temp_dir}\\scripts\\winmerge\\install_winmerge.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -install",
      # "${var.win_temp_dir}\\scripts\\texstudio\\install_texstudio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -install",
      # "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
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
      "${var.win_temp_dir}\\scripts\\Microsoft\\install_adk.ps1 -SearchPath '${var.win_temp_dir}\\apps' -installername 'adksetup.exe' -app 'msadk'",
      "${var.win_temp_dir}\\scripts\\Microsoft\\install_winpeadk.ps1 -SearchPath '${var.win_temp_dir}\\apps' -installername 'adkwinpesetup.exe' -app 'mswinpeadk'",
      # "'${var.win_temp_dir}\\psappdeploy\\ms_adk\\Deploy-Application.ps1 -DeploymentType Install -DeployMode Silent",
      # "${var.win_temp_dir}\\scripts\\CiscoAnyconnect\\install_anyconnect.ps1 -Cleanup -uri 'http://${build.PackerHTTPAddr}' -OutPath '${var.win_temp_dir}' -installername '${var.anyconnect_installer}' -install",
      "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
      ]
  }
}

build { 
  name = "win_base_optimize"
  sources = ["source.qemu.Windows10_base"]

  provisioner "powershell" {
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}' -sdelete"
      ]
  }
}
