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

variable "vm_ipaddress" {
  type    = string
  default = ""
}

variable "vm_prefixlength" {
  type    = string
  default = ""
}

variable "vm_subnetmask" {
  type    = string
  default = ""
}

variable "vm_defaultgateway" {
  type    = string
  default = ""
}

variable "anaconda_install_type" {
  type    = string
  default = "/InstallationType=AllUsers"
}

variable "anaconda_install_addpath" {
  type    = string
  default = "/AddToPath=1"
}

variable "anaconda_install_registerpy" {
  type    = string
  default = "/RegisterPython=1"
}

variable "anaconda_install_silent" {
  type    = string
  default = "/S"
}

variable "anaconda_install_dir" {
  type    = string
  default =  "C:\\programdata\\Anaconda3"
}

variable "r" {
  type  = map(string)
}

variable "r_studio" {
  type  = map(string)
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

source "qemu" "win_iso" {
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

source "hyperv-iso" "win_iso" {
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
  sources = ["source.qemu.win_iso","source.hyperv-iso.win_iso"]

  provisioner "powershell" {
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:/Config_Winrm.ps1",
      "a:/Windows_os_optimize.ps1 -defaultsUserSettingsPath 'a:\\DefaultUsersSettings.txt' -ScheduledTasksListPath 'a:\\ScheduledTasks.txt' -automaticTracingFilePath 'a:\\AutomaticTracers.txt' -servicesToDisablePath 'a:\\ServicesToDisable.txt'"
    ]
  }

  provisioner "powershell" {
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:/Install_dotnet3.5.ps1",
    ]
  }

    provisioner "powershell" {
    inline = [
      "a:/OneDrive_removal.ps1"
    ]
  }

}

build { 
  name = "win_base"
  sources = ["source.hyperv-vmcx.Windows_base"]

  provisioner "file" {
    source      = "./src/apps/wget"
    destination = "${var.win_temp_dir}/"
    direction   =  "upload"
  }

  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
      "a:/download_installers.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -wgetPath '${var.win_temp_dir}\\wget\\wget.exe'",
      # "a:\\psappdeploy\\Virtio\\install_Virtio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -isoname '${var.virtio_isoname}' -install",
      "a:\\Install_pswindowsupdate.ps1",
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -SearchPath '${var.win_temp_dir}\\apps' -app 'sysinternals'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '7zip' -installParams '/S' -installername '7z2107-x64.exe'",
      "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Chrome' -installParams '/quiet /norestart' -installername 'GoogleChromeStandaloneEnterprise64.msi'",
      "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome_MasterPrefs.ps1 -SearchPath '${var.win_temp_dir}\\scripts'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Git' -installParams '/VERYSILENT /NORESTART' -installername 'Git-2.36.1-64-bit.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Git LFS' -installParams '/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -installername 'git-lfs-windows-v3.2.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'VSCode' -installParams '/VERYSILENT /loadinf=vscode.inf /MERGETASKS=!runcode' -installername 'VSCodeSetup-x64-1.67.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Python2.7' -installParams '/quiet' -installername 'python-2.7.18.amd64.msi'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Python 3.9.13' -installParams '/quiet' -installername 'python-3.9.13-amd64.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.r, "name", "R")}' -installParams '${lookup(var.r, "parameters", "/verysilent /NORESTART /MERGETASKS=!desktopicon")}' -installername '${lookup(var.r,"installer","R-4.2.0-win.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Anaconda3 2021.11' -installParams '${var.anaconda_install_silent} ${var.anaconda_install_registerpy} ${var.anaconda_install_addpath} ${var.anaconda_install_type}' -installername 'Anaconda3-2021.11-Windows-x86_64.exe'",
      "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -SearchPath '${var.win_temp_dir}' -app 'Firefox' -installername 'Firefox Setup 101.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.r_studio, "name","R Studio 2022.02.1-461")}' -installParams '${lookup(var.r_studio, "parameters","/S")}' -installername '${lookup(var.r_studio,"installer","RStudio-2022.02.1-461.exe")}'", 
      "${var.win_temp_dir}\\scripts\\Rstudio\\copy_rstudio_confs.ps1 -SearchPath '${var.win_temp_dir}' -crashHandlerFile 'crash-handler.conf' -preferenceFile 'rstudio-prefs.json' -preferencesDestination 'C:\\ProgramData\\Rstudio' -crashHandlerDestination 'C:\\Program Files\\RStudio'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Atom' -installParams '-s' -installername 'AtomSetup-x64.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Notepad++' -installParams '/S' -installername 'npp.8.4.1.Installer.x64.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'WinMerge' -installParams '/VERYSILENT /NORESTART /MERGETASKS=!desktopicon' -installername 'WinMerge-2.16.20-x64-Setup.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'MikTex' -installParams '--verbose --local-package-repository=C:\\temp\\apps\\miktex\\repo --shared=yes install' -installername 'miktexsetup_standalone.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Tex Studio' -installParams '/S' -installername 'texstudio-4.2.3-win-qt6.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'FileShredder' -installParams '/SILENT' -installername 'file_shredder_setup.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'SpeedCrunch' -installParams '/S' -installername 'SpeedCrunch-0.12-win32.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Java 8 R333 x86' -installParams 'INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg' -installername 'jre-8u333-windows-i586.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Java 8 R333 x64' -installParams 'INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg' -installername 'jre-8u333-windows-x64.exe'", 
      # Conda Navigator update
      # "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
    ]
  }
}

build { 
  name = "win_base"
  sources = ["source.qemu.Windows10_base"]

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
      "a:\\psappdeploy\\Virtio\\install_Virtio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -isoname '${var.virtio_isoname}' -install",
      "a:\\Install_pswindowsupdate.ps1",
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -SearchPath '${var.win_temp_dir}\\apps' -app 'sysinternals'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '7zip' -installParams '/S' -installername '7z2107-x64.exe'",
      "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Chrome' -installParams '/quiet /norestart' -installername 'GoogleChromeStandaloneEnterprise64.msi'",
      "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome_MasterPrefs.ps1 -SearchPath '${var.win_temp_dir}\\scripts'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Git' -installParams '/VERYSILENT /NORESTART' -installername 'Git-2.36.1-64-bit.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Git LFS' -installParams '/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -installername 'git-lfs-windows-v3.2.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'VSCode' -installParams '/VERYSILENT /loadinf=vscode.inf /MERGETASKS=!runcode' -installername 'VSCodeSetup-x64-1.67.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Python2.7' -installParams '/quiet' -installername 'python-2.7.18.amd64.msi'",
      # "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Python 3.9.13' -installParams '/quiet' -installername 'python-3.9.13-amd64.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'R 4.2.0' -installParams '/verysilent /NORESTART /MERGETASKS=!desktopicon' -installername 'R-4.2.0-win.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Anaconda3 2021.11' -installParams '${var.anaconda_install_silent} ${var.anaconda_install_registerpy} ${var.anaconda_install_addpath} ${var.anaconda_install_type}' -installername 'Anaconda3-2021.11-Windows-x86_64.exe'",
      "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -SearchPath '${var.win_temp_dir}' -app 'Firefox' -installername 'Firefox Setup 101.0.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'R Studio 2022.02.1-461' -installParams '/S' -installername 'RStudio-2022.02.1-461.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Atom' -installParams '-s' -installername 'AtomSetup-x64.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Notepad++' -installParams '/S' -installername 'npp.8.4.1.Installer.x64.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'WinMerge' -installParams '/VERYSILENT /NORESTART /MERGETASKS=!desktopicon' -installername 'WinMerge-2.16.20-x64-Setup.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'MikTex' -installParams '--verbose --local-package-repository=C:\\temp\\apps\\miktex\\repo --shared=yes --print-info-only install' -installername 'miktexsetup_standalone.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Tex Studio' -installParams '/S' -installername 'texstudio-4.2.3-win-qt6.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'FileShredder' -installParams '/SILENT' -installername 'file_shredder_setup.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'SpeedCrunch' -installParams '/S' -installername 'SpeedCrunch-0.12-win32.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Java 8 R333 x86' -installParams 'INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg' -installername 'jre-8u333-windows-i586.exe'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app 'Java 8 R333 x64' -installParams 'INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg' -installername 'jre-8u333-windows-x64.exe'", 
    ]
  }
}

build { 
  name = "win_base_apps1"
  sources = ["source.qemu.Windows10_base","source.hyperv-vmcx.Windows_base"]

  # provisioner "file" {
  #   source      = "./src/scripts/"
  #   destination = "${var.win_temp_dir}/scripts/"
  #   direction   =  "upload"
  # }

# Application installations
  provisioner "powershell" {
    inline = [
      "a:/download_installers.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -wgetPath '${var.win_temp_dir}\\wget\\wget.exe'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath  '${var.win_temp_dir}' -installername 'adksetup.exe' -app 'msadk' -installParams '/ceip off /norestart /quiet /features OptionId.WindowsPerformanceToolkit OptionId.DeploymentTools OptionId.ApplicationCompatibilityToolkit OptionId.WindowsAssessmentToolkit'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -installername 'adkwinpesetup.exe' -app 'mswinpeadk' -installParams '/ceip off /norestart /quiet' ",
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
