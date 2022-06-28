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
  type = map(string)
}

variable "r_studio" {
  type = map(string)
}
variable "seven_zip" {
  type = map(string)
}

variable "chrome" {
  type = map(string)
}

variable "git" {
  type = map(string)
}

variable "git_lfs" {
  type = map(string)
}

variable "vscode" {
  type = map(string)
}

variable "python_27" {
  type = map(string)
}

variable "python_39" {
  type = map(string)
}

variable "conda" {
  type = map(string)
}

variable "firefox" {
  type = map(string)
}

variable "atom" {
  type = map(string)
}

variable "npp" {
  type = map(string)
}

variable "winmerge" {
  type = map(string)
}

variable "miktex" {
  type = map(string)
}

variable "texstudio" {
  type = map(string)
}

variable "fileshredder" {
  type  = map(string)
}

variable "speedcrunch" {
  type = map(string)
}

variable "java_x86" {
  type = map(string)
}

variable "java_x64" {
  type = map(string)
}
variable "julia" {
  type = map(string)
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

  provisioner "file" {
    source      = "./src/apps/wget"
    destination = "'${var.wget_path}\\'"
    direction   =  "upload"
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

  provisioner "powershell" {
    inline = [
      "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
    ]
  }
}

build { 
  name = "win_base"
  sources = ["source.hyperv-vmcx.Windows_base"]

  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
      "a:/download_installers.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -wgetPath '${var.wget_path}\\wget.exe'",
      # "a:\\psappdeploy\\Virtio\\install_Virtio.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -isoname '${var.virtio_isoname}' -install",
      # Utilities
      "a:\\Install_pswindowsupdate.ps1",
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -SearchPath '${var.win_temp_dir}\\apps' -app 'sysinternals'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.seven_zip, "name", "7zip")}' -installParams '${lookup(var.seven_zip, "parameters", "/S")}' -installername '${lookup(var.seven_zip, "installer", "7z2107-x64.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.fileshredder, "name", "FileShredder")}' -installParams '${lookup(var.fileshredder, "parameters", "/SILENT")}' -installername '${lookup(var.fileshredder, "installer", "file_shredder_setup.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.speedcrunch, "name", "SpeedCrunch")}' -installParams '${lookup(var.speedcrunch, "parameters", "/S")}' -installername '${lookup(var.speedcrunch,"installer", "SpeedCrunch-0.12-win32.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.winmerge, "name", "WinMerge")}' -installParams '${lookup(var.winmerge, "parameters", "/VERYSILENT /NORESTART /MERGETASKS=!desktopicon")}' -installername '${lookup(var.winmerge,"installer", "WinMerge-2.16.20-x64-Setup.exe")}'", 
      # Web Browsers
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.chrome, "name", "Chrome")}' -installParams '${lookup(var.chrome, "parameters", "/quiet /norestart")}' -installername '${lookup(var.chrome,"installer","GoogleChromeStandaloneEnterprise64.msi")}'",
      "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.firefox, "name", "Firefox")}' -installername '${lookup(var.firefox,"installer","Firefox Setup 101.0.exe")}'",
      # Git and Git LFS
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.git, "name", "Git")}' -installParams '${lookup(var.git, "parameters", "/VERYSILENT /NORESTART")}' -installername '${lookup(var.git, "installer", "Git-2.36.1-64-bit.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.git_lfs, "name", "Git LFS")}' -installParams '${lookup(var.git_lfs, "parameters", "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART")}' -installername '${lookup(var.git_lfs ,"installer", "git-lfs-windows-v3.2.0.exe")}'",
      # Text and Code Editors
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.vscode, "name", "VSCode")}' -installParams '${lookup(var.vscode, "parameters", "/VERYSILENT /loadinf=vscode.inf /MERGETASKS=!runcode")}' -installername '${lookup(var.vscode, "installer", "VSCodeSetup-x64-1.67.0.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.atom, "name", "Atom")}' -installParams '${lookup(var.atom, "parameters", "-s")}' -installername '${lookup(var.atom,"installer", "AtomSetup-x64.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.npp, "name", "Notepad++")}' -installParams '${lookup(var.npp, "parameters", "/S")}' -installername '${lookup(var.npp,"installer", "npp.8.4.1.Installer.x64.exe")}'",
      # Python and Conda
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.python_27, "name", "Python2.7")}' -installParams '${lookup(var.python_27, "parameters", "/quiet")}' -installername '${lookup(var.python_27, "installer", "python-2.7.18.amd64.msi")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.python_39, "name", "Python 3.9.13")}' -installParams '${lookup(var.python_39, "parameters", "/quiet")}' -installername '${lookup(var.python_39, "installer", "python-3.9.13-amd64.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.conda, "name", "Anaconda3 2021.11")}' -installParams '${lookup(var.conda, "parameters", "/S /RegisterPython=1 /AddToPath=1 /InstallationType=AllUsers")}' -installername '${lookup(var.conda, "installer", "Anaconda3-2021.11-Windows-x86_64.exe")}'",
      # R and R Studio
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.r, "name", "R")}' -installParams '${lookup(var.r, "parameters", "/verysilent /NORESTART /MERGETASKS=!desktopicon")}' -installername '${lookup(var.r, "installer", "R-4.2.0-win.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.r_studio, "name","R Studio 2022.02.1-461")}' -installParams '${lookup(var.r_studio, "parameters","/S")}' -installername '${lookup(var.r_studio,"installer","RStudio-2022.02.1-461.exe")}'", 
            # Java
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.java_x86, "name", "Java 8 R333 x86")}' -installParams '${lookup(var.java_x86, "parameters", "INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg")}' -installername '${lookup(var.java_x86, "installer", "jre-8u333-windows-i586.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.java_x64, "name","Java 8 R333 x64")}' -installParams '${lookup(var.java_x64, "parameters", "INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg")}' -installername '${lookup(var.java_x64, "installer", "jre-8u333-windows-x64.exe")}'", 
      # Julia
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.julia, "name","Julia")}' -installParams '${lookup(var.julia, "parameters", "/SP /verysilent /allusers")}' -installername '${lookup(var.julia, "installer", "julia-1.7.3-win32.exe")}'", 
      ]
  }

  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
       # TexStudio and Miktex
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.miktex, "name", "MikTex")}' -installParams '${lookup(var.miktex, "parameters", "--verbose --local-package-repository=C:\\temp\\apps\\miktex\\repo --shared=yes install")}' -installername '${lookup(var.miktex,"installer", "miktexsetup_standalone.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.texstudio, "name", "TexStudio")}' -installParams '${lookup(var.texstudio, "parameters", "/S")}' -installername '${lookup(var.texstudio,"installer", "texstudio-4.2.3-win-qt6.exe")}'", 
    ]
  }

  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
      # App Customization
      "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome_MasterPrefs.ps1 -SearchPath '${var.win_temp_dir}\\scripts'",
      "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      "${var.win_temp_dir}\\scripts\\Rstudio\\copy_rstudio_confs.ps1 -SearchPath '${var.win_temp_dir}' -crashHandlerFile 'crash-handler.conf' -preferenceFile 'rstudio-prefs.json' -preferencesDestination 'C:\\ProgramData\\Rstudio' -crashHandlerDestination 'C:\\ProgramData\\RStudio'",
      "${var.win_temp_dir}\\scripts\\notepadplusplus\\npp_disable_updates.ps1",
      "${var.win_temp_dir}\\scripts\\julia\\julia_addToPath.ps1",
      # Conda Navigator update
      "${var.win_temp_dir}\\scripts\\anaconda\\conda_update_navigator.ps1",
      # "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
    ]
  }
}

build { 
  name = "win_base"
  sources = ["source.qemu.Windows10_base"]

  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
      "a:/download_installers.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -wgetPath '${var.wget_path}\\wget.exe'",
       "${var.win_temp_dir}\\scripts\\Virtio\\install_virtio.ps1 -outpath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}/apps/Virtio/virtio-win-0.1.217.iso'",
      # Utilities
      "a:\\Install_pswindowsupdate.ps1",
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -SearchPath '${var.win_temp_dir}\\apps' -app 'sysinternals'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.seven_zip, "name", "7zip")}' -installParams '${lookup(var.seven_zip, "parameters", "/S")}' -installername '${lookup(var.seven_zip, "installer", "7z2107-x64.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.fileshredder, "name", "FileShredder")}' -installParams '${lookup(var.fileshredder, "parameters", "/SILENT")}' -installername '${lookup(var.fileshredder, "installer", "file_shredder_setup.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.speedcrunch, "name", "SpeedCrunch")}' -installParams '${lookup(var.speedcrunch, "parameters", "/S")}' -installername '${lookup(var.speedcrunch,"installer", "SpeedCrunch-0.12-win32.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.winmerge, "name", "WinMerge")}' -installParams '${lookup(var.winmerge, "parameters", "/VERYSILENT /NORESTART /MERGETASKS=!desktopicon")}' -installername '${lookup(var.winmerge,"installer", "WinMerge-2.16.20-x64-Setup.exe")}'", 
      # Web Browsers
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.chrome, "name", "Chrome")}' -installParams '${lookup(var.chrome, "parameters", "/quiet /norestart")}' -installername '${lookup(var.chrome,"installer","GoogleChromeStandaloneEnterprise64.msi")}'",
      "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.firefox, "name", "Firefox")}' -installername '${lookup(var.firefox,"installer","Firefox Setup 101.0.exe")}'",
      # Git and Git LFS
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.git, "name", "Git")}' -installParams '${lookup(var.git, "parameters", "/VERYSILENT /NORESTART")}' -installername '${lookup(var.git, "installer", "Git-2.36.1-64-bit.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.git_lfs, "name", "Git LFS")}' -installParams '${lookup(var.git_lfs, "parameters", "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART")}' -installername '${lookup(var.git_lfs ,"installer", "git-lfs-windows-v3.2.0.exe")}'",
      # Text and Code Editors
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.vscode, "name", "VSCode")}' -installParams '${lookup(var.vscode, "parameters", "/VERYSILENT /loadinf=vscode.inf /MERGETASKS=!runcode")}' -installername '${lookup(var.vscode, "installer", "VSCodeSetup-x64-1.67.0.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.atom, "name", "Atom")}' -installParams '${lookup(var.atom, "parameters", "-s")}' -installername '${lookup(var.atom,"installer", "AtomSetup-x64.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.npp, "name", "Notepad++")}' -installParams '${lookup(var.npp, "parameters", "/S")}' -installername '${lookup(var.npp,"installer", "npp.8.4.1.Installer.x64.exe")}'",
      # Python and Conda
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.python_27, "name", "Python2.7")}' -installParams '${lookup(var.python_27, "parameters", "/quiet")}' -installername '${lookup(var.python_27, "installer", "python-2.7.18.amd64.msi")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.python_39, "name", "Python 3.9.13")}' -installParams '${lookup(var.python_39, "parameters", "/quiet")}' -installername '${lookup(var.python_39, "installer", "python-3.9.13-amd64.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.conda, "name", "Anaconda3 2021.11")}' -installParams '${lookup(var.conda, "parameters", "/S /RegisterPython=1 /AddToPath=1 /InstallationType=AllUsers")}' -installername '${lookup(var.conda, "installer", "Anaconda3-2021.11-Windows-x86_64.exe")}'",
      # R and R Studio
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.r, "name", "R")}' -installParams '${lookup(var.r, "parameters", "/verysilent /NORESTART /MERGETASKS=!desktopicon")}' -installername '${lookup(var.r, "installer", "R-4.2.0-win.exe")}'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.r_studio, "name","R Studio 2022.02.1-461")}' -installParams '${lookup(var.r_studio, "parameters","/S")}' -installername '${lookup(var.r_studio,"installer","RStudio-2022.02.1-461.exe")}'", 
            # Java
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.java_x86, "name", "Java 8 R333 x86")}' -installParams '${lookup(var.java_x86, "parameters", "INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg")}' -installername '${lookup(var.java_x86, "installer", "jre-8u333-windows-i586.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.java_x64, "name","Java 8 R333 x64")}' -installParams '${lookup(var.java_x64, "parameters", "INSTALLCFG=${var.win_temp_dir}\\apps\\java\\java_install.cfg")}' -installername '${lookup(var.java_x64, "installer", "jre-8u333-windows-x64.exe")}'", 
      # Julia
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.julia, "name","Julia")}' -installParams '${lookup(var.julia, "parameters", "/SP /verysilent /allusers")}' -installername '${lookup(var.julia, "installer", "julia-1.7.3-win32.exe")}'", 
      ]
  }

  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
       # TexStudio and Miktex
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.miktex, "name", "MikTex")}' -installParams '${lookup(var.miktex, "parameters", "--verbose --local-package-repository=C:\\temp\\apps\\miktex\\repo --shared=yes install")}' -installername '${lookup(var.miktex,"installer", "miktexsetup_standalone.exe")}'", 
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.texstudio, "name", "TexStudio")}' -installParams '${lookup(var.texstudio, "parameters", "/S")}' -installername '${lookup(var.texstudio,"installer", "texstudio-4.2.3-win-qt6.exe")}'", 
    ]
  }
  
  provisioner "powershell" {
    # elevated_user = "SYSTEM"
    # elevated_password = ""
    inline = [
      # App Customization
      "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome_MasterPrefs.ps1 -SearchPath '${var.win_temp_dir}\\scripts'",
      "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      "${var.win_temp_dir}\\scripts\\Rstudio\\copy_rstudio_confs.ps1 -SearchPath '${var.win_temp_dir}' -crashHandlerFile 'crash-handler.conf' -preferenceFile 'rstudio-prefs.json' -preferencesDestination 'C:\\ProgramData\\Rstudio' -crashHandlerDestination 'C:\\ProgramData\\RStudio'",
      "${var.win_temp_dir}\\scripts\\notepadplusplus\\npp_disable_updates.ps1",
      "${var.win_temp_dir}\\scripts\\julia\\julia_addToPath.ps1",
      # Conda Navigator update
      "${var.win_temp_dir}\\scripts\\anaconda\\conda_update_navigator.ps1",
      # "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}'"
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
      "a:/download_installers.ps1 -OutPath '${var.win_temp_dir}' -uri 'http://${build.PackerHTTPAddr}' -wgetPath '${var.wget_path}\\wget.exe'",
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
  sources = ["source.qemu.Windows10_base","source.hyperv-vmcx.Windows_base"]

  provisioner "powershell" {
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}' -sdelete"
      ]
  }
}
