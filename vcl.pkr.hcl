# Packer Variables
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

variable "use_backing_file" {
  type    = string
  default = false
}

variable "clone_from_vmcx_path" {
  type    = string
  default = ""
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

variable "boot_wait" {
  type    = string
  default = "60s"
}

# Build Specific variables
variable "elevated_user" {
  type    = string
  default = ""
}

variable "elevated_pwd" {
  sensitive = true
  type    = string
  default = ""

}
variable "net_drive" {
  type    = string
  default = "z:"
}

variable "os_hostname" {
  type    = string
  default = ""
}

variable "net_pass" {
   sensitive = true
  type    = string
  default = ""
}
variable "net_user" {
  type    = string
  default = ""
}
variable "net_path" {
  type    = string
  default = ""
}
variable "vm_name" {
  type    = string
  default = "${env("vm_name")}"
}

variable "audit_json_path"{
  type = string
}

variable "audit_json_file"{
  type = string
}

variable "vmx_version" {
  type    = string
  default = "14"
}

variable "win_temp_dir" {
  type    = string
  default = "${env("win_temp_dir")}"
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

variable "wget_path" {
  type    = string
  default = "c:\\Program Files\\wget"
}

# WinRM Variables
variable "winrm_insecure" {
  type    = string
  default = "${env("winrm_insecure")}"
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

variable "winrm_password" {
  sensitive = true
  type    = string
  default = "${env("winrm_password")}"
}
# SSH Variables
variable "ssh_username" {
  type    = string
  default = ""
}

variable "ssh_password" {
  sensitive = true
  type    = string
  default = ""
}

#VMware variables
variable "vmware_username" {
  type    = string
  default = ""
}

variable "vmware_password" {
  sensitive = true
  type    = string
  default = ""
}

variable "tools_upload_flavor" {
  type    = string
  default = ""
}

variable "vmware_network_adapter_type" {
  type    = string
  default = ""
}

variable "vmware_disk_adapter_type" {
  type    = string
  default = ""
}

variable "vmware_guest_os_type" {
  type    = string
  default = ""
}

variable "vcenter_server" {
  type    = string
  default = ""
}

variable "datastore" {
  type    = string
  default = ""
}
# Application specific map variables
variable "win_startmenu_xml" {
  type    = string
  default = ""
}

variable "vmware_tools" {
  type = map(string)
}

variable "os_optimize" {
  type = map(string)
}

variable "vcl" {
  type = map(string)
}

variable "cygwin" {
  type = map(string)
}

variable "winscp" {
  type = map(string)
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

variable "vim" {
  type = map(string)
}

variable "r_tools_40" {
  type = map(string)
}

variable "docker" {
  type = map(string)
}

variable "build_public_mac" {
  type = string
}

variable "deploy_public_mac" {
  type = string
}

variable "build_private_mac" {
  type = string
}

variable "deploy_private_mac" {
  type = string
}

packer {
}

source "vmware-iso" "win10_iso" {
  # http_directory   = "${var.http_directory}"
  headless         = "true"

  boot_wait        = "${var.boot_wait}"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  memory           = "${var.memory}"

  disk_adapter_type = "${var.vmware_disk_adapter_type}"
  disk_size         = "${var.disk_size}"

  network_name = "Packer"
  network_adapter_type = "${var.vmware_network_adapter_type}"
 
  guest_os_type    = "${var.vmware_guest_os_type}"
  vm_name          = "${var.vm_name}"
 
  tools_upload_flavor = "${var.tools_upload_flavor}"

  floppy_files     = ["${var.autounattend}","./src/scripts/","./src/apps/VMware/floppies/pvscsi-Windows8/AMD64/"]
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"

  shutdown_command = "${var.shutdown_command}"

  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"

  insecure_connection  = "true"
  remote_type = "esx5"
  remote_host = "${var.vcenter_server}"
  remote_datastore = "${var.datastore}"
  remote_username = "${var.vmware_username}"
  remote_password  = "${var.vmware_password}"
  vnc_disable_password = "true"

  keep_registered = "true"
  skip_export = "true"
  vmx_data = {
    "ethernet0.address" = "${var.build_public_mac}"
    "ethernet0.addressType" = "static"
    # "ethernet0.connectionType" = "custom"
    "ethernet0.networkName" = "Public"
    "ethernet0.present" = "TRUE"
    # "ethernet0.virtualDev" = "e1000e"
    # "ethernet1.address" = "${var.build_private_mac}"
    # "ethernet1.addressType" = "static"
    # "ethernet1.connectionType" = "custom"
    # "ethernet1.networkName "= "Private"
    # "ethernet1.present" = "TRUE"
    # "ethernet1.virtualDev" = "e1000e"
    "featMask.vm.hv.capable" = "Min:1"
    "mem.hotadd" = "TRUE"
    "toolScripts.afterPowerOn" = "FALSE"
    "toolScripts.afterResume" = "FALSE"
    "toolScripts.beforePowerOff" = "FALSE"
    "toolScripts.beforeSuspend" = "FALSE"
    "tools.remindInstall" = "FALSE"
    "tools.syncTime" = "FALSE"
    "vcpu.hotadd" = "TRUE"
    "vhv.enable" = "TRUE"
    "usb_xhci.present" = "TRUE" 
    "virtualHW.version" = "15"
    "tools.upgrade.policy" = "manual"
    }
  vmx_data_post = {
    "ethernet0.address" = "${var.deploy_public_mac}"
    "ethernet0.addressType" = "static"
    "ethernet0.connectionType" = "custom"
    "ethernet0.networkName" = "Public"
    "ethernet0.present" = "TRUE"
    "ethernet0.virtualDev" = "e1000e"
    "ethernet1.address" = "${var.deploy_private_mac}"
    "ethernet1.addressType" = "static"
    "ethernet1.connectionType" = "custom"
    "ethernet1.networkName "= "Private"
    "ethernet1.present" = "TRUE"
    "ethernet1.virtualDev" = "e1000e"
    "ide1:0.present" = "FALSE"
  }
}

source "vmware-iso" "win11_iso" {
  # http_directory   = "${var.http_directory}"
  headless         = "true"
  boot_wait        = "10m"
  communicator     = "winrm"
  cpus             = "${var.cpu_num}"
  memory           = "${var.memory}"

  disk_adapter_type = "${var.vmware_disk_adapter_type}"
  disk_size         = "${var.disk_size}"

  network_name = "Packer"
  network_adapter_type = "${var.vmware_network_adapter_type}"
 
  guest_os_type    = "${var.vmware_guest_os_type}"
  vm_name          = "${var.vm_name}"
 
  tools_upload_flavor = "${var.tools_upload_flavor}"

  floppy_files     = ["${var.autounattend}","./src/scripts/","./src/apps/VMware/floppies/pvscsi-Windows8/AMD64/"]
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"

  shutdown_command = "${var.shutdown_command}"

  winrm_insecure   = "${var.winrm_insecure}"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_use_ntlm   = "${var.winrm_use_ntlm}"
  winrm_use_ssl    = "${var.winrm_use_ssl}"
  winrm_username   = "${var.winrm_username}"

  insecure_connection  = "true"
  remote_type = "esx5"
  remote_host = "${var.vcenter_server}"
  remote_datastore = "${var.datastore}"
  remote_username = "${var.vmware_username}"
  remote_password  = "${var.vmware_password}"
  vnc_disable_password = "true"

  keep_registered = "true"
  skip_export = "true"
  vmx_data = {
    "ethernet0.address" = "${var.build_public_mac}"
    "ethernet0.addressType" = "static"
    "ethernet0.connectionType" = "custom"
    "ethernet0.networkName" = "Public"
    "ethernet0.present" = "TRUE"
    "ethernet0.virtualDev" = "e1000e"
    # "ethernet1.address" = "${var.build_private_mac}"
    # "ethernet1.addressType" = "static"
    # "ethernet1.connectionType" = "custom"
    # "ethernet1.networkName "= "Private"
    # "ethernet1.present" = "TRUE"
    # "ethernet1.virtualDev" = "e1000e"
    "featMask.vm.hv.capable" = "Min:1"
    "mem.hotadd" = "TRUE"
    "toolScripts.afterPowerOn" = "TRUE"
    "toolScripts.afterResume" = "TRUE"
    "toolScripts.beforePowerOff" = "TRUE"
    "toolScripts.beforeSuspend" = "TRUE"
    "tools.remindInstall" = "FALSE"
    "tools.syncTime" = "FALSE"
    "vcpu.hotadd" = "TRUE"
    "vhv.enable" = "FALSE"
    "usb_xhci.present" = "TRUE" 
    "firmware" = "efi"
    "uefi.secureBoot.enabled" = "FALSE"
    "vvtd.enable" = "FALSE"
    "windows.vbs.enabled" = "FALSE"
    "disk.EnableUUID" = "TRUE"
    }
  vmx_data_post = {
    "ethernet0.address" = "${var.deploy_public_mac}"
    "ethernet0.addressType" = "static"
    "ethernet0.connectionType" = "custom"
    "ethernet0.networkName" = "Public"
    "ethernet0.present" = "TRUE"
    "ethernet0.virtualDev" = "e1000e"
    "ethernet1.address" = "${var.deploy_private_mac}"
    "ethernet1.addressType" = "static"
    "ethernet1.connectionType" = "custom"
    "ethernet1.networkName "= "Private"
    "ethernet1.present" = "TRUE"
    "ethernet1.virtualDev" = "e1000e"
    "ide1:0.present" = "FALSE"
  }
}


build {
  name = "windows_base"
  sources = ["source.vmware-iso.win10_iso","source.vmware-iso.win11_iso"]

  provisioner "powershell" {
    elevated_user     = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:/Config_Winrm.ps1",
      # "a:/Create_wget_directory.ps1 -wgetPath '${var.wget_path}'",
      "a:/OneDrive_removal.ps1",
      "a:/Windows_Disable_Updates.ps1",
      "a:/download_installers.ps1 -outpath '${var.win_temp_dir}' -drive '${var.net_drive}' -network -netpath '${var.net_path}' -user '${var.net_user}' -pass '${var.net_pass}'",
    ]
  }

  # VMware tools installation
    provisioner "powershell" {
    elevated_user     = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:/Install_dotnet3.5.ps1",
      # "Start-Process -NoNewWindow -Wait -FilePath \"${var.win_temp_dir}\\apps\\vmware\\vmtools\\windows\\setup.exe\" -ArgumentList \"/S /v /qn REBOOT=R ADDLOCAL=ALL REMOVE=Hgfs,FileIntrospection,NetworkIntrospection,BootCamp,CBHelper\"",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}\\apps\\vmware\\vmtools\\windows' -app '${lookup(var.vmware_tools, "name", "VMWare Tools")}' -installParams \"${lookup(var.vmware_tools, "parameters", "\"/S /v /qn REBOOT=R ADDLOCAL=ALL REMOVE=Hgfs,FileIntrospection,NetworkIntrospection,BootCamp,CBHelper\"")}\" -installername '${lookup(var.vmware_tools,"installer","setup.exe")}'",
      "a:/set_win_hostname.ps1 -hostname '${var.os_hostname}'",
    ]
  }
 
  # Reboot for VMware tools installation
  provisioner "windows-restart" {}

  # provisioner "file" {
  #   source      = "./src/apps/wget/"
  #   destination = "${var.wget_path}"
  #   direction   =  "upload"
  # }

  provisioner "powershell" {
    inline = [
      # Powershell tools
      "a:\\Install_pswindowsupdate.ps1",
      "a:\\Install_pester.ps1 -remove",
      # OS Utilities
      "${var.win_temp_dir}\\scripts\\BGInfo\\install_BGInfo.ps1 -SearchPath '${var.win_temp_dir}\\apps' -app 'sysinternals'",
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.seven_zip, "name", "7zip")}' -installParams '${lookup(var.seven_zip, "parameters", "/S")}' -installername '${lookup(var.seven_zip, "installer", "7z2107-x64.exe")}'",
      # Web Browsers
      "${var.win_temp_dir}\\scripts\\install_app.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.chrome, "name", "Chrome")}' -installParams '${lookup(var.chrome, "parameters", "/quiet /norestart")}' -installername '${lookup(var.chrome,"installer","GoogleChromeStandaloneEnterprise64.msi")}'",
      "${var.win_temp_dir}\\scripts\\Firefox\\install_firefox.ps1 -SearchPath '${var.win_temp_dir}' -app '${lookup(var.firefox, "name", "Firefox")}' -installername '${lookup(var.firefox,"installer","Firefox Setup 101.0.exe")}'",
      # Cygwin Install
      # "${var.win_temp_dir}\\scripts\\cygwin\\install_cygwin.ps1 -cygwinroot '${lookup(var.cygwin, "root", "C:\\cygwin")}' -pass '${var.winrm_password}' -vclscriptpath '${var.win_temp_dir}\\scripts\\cygwin\\cygwin-sshd-config.sh'",
      # "${var.win_temp_dir}\\scripts\\cygwin\\cygwin-rebaseall.ps1 -cygwinroot '${lookup(var.cygwin, "root", "C:\\cygwin")}'",

    ]
  }


  provisioner "powershell" {
    inline = [
      # App Customization
      "${var.win_temp_dir}\\scripts\\Chrome\\install_Chrome_MasterPrefs.ps1 -SearchPath '${var.win_temp_dir}\\scripts'",
      "${var.win_temp_dir}\\scripts\\Edge\\install_edge.ps1 -OutPath '${var.win_temp_dir}' -install",
      # VCL Customization
      "${var.win_temp_dir}\\scripts\\VCL\\copy_vcl_scripts.ps1 -searchPath '${lookup(var.vcl, "src_path", "C:\\temp")}' -scriptsPath '${lookup(var.vcl, "script_path", "C:\\Scripts")}' -packerScriptsPath ${var.win_temp_dir}",
      # Cygwin Customization
      # "${var.win_temp_dir}\\scripts\\cygwin\\customize_cygwin.ps1 -renamesvc -nopublicIcon -sourcePath '${var.win_temp_dir}\\apps\\cygwin' -cygwinroot '${lookup(var.cygwin, "root", "C:\\cygwin")}'",
      "a:/Windows_os_optimize.ps1 -defaultsUserSettingsPath '${lookup(var.os_optimize, "defaultsUserSettingsPath", "a:\\DefaultUserSettings.txt")}' -ScheduledTasksListPath '${lookup(var.os_optimize, "ScheduledTasksListPath", "a:\\ScheduledTasks.txt")}' -automaticTracingFilePath '${lookup(var.os_optimize, "automaticTracingFilePath", "a:\\AutomaticTracers.txt")}' -servicesToDisablePath '${lookup(var.os_optimize, "servicesToDisablePath", "a:\\ServicesToDisable.txt")}'",
      "${var.win_temp_dir}\\scripts\\import_startmenu_xml.ps1 -searchpath '${var.win_temp_dir}' -startmenufile 'Windows11_base_202210100336.json'",
    ]
  }

  # Reboot before optimiziation
  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user = "SYSTEM"
    elevated_password = ""
    inline = [
      "a:\\Windows_vm_optimize.ps1 -outpath '${var.win_temp_dir}' -sdelete"
      ]
  }
}

 