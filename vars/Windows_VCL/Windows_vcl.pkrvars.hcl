vm_name = "Windows10_{{isotime \"20060102_1504\"}}"
nix_output_directory = "/home/libvirt/images/pool/Win10/Win10_{{isotime \"20060102_1504\"}}/"
output_directory = "D:\\Hyperv\\packer\\windows10_21h2"
cpu_num = "6"
disk_size = "80000"
memory = "8192"
iso_checksum = "sha256:5CE075F3DAD396A6532625B7040B3042CFB23A62EC4D1C65374D1CAB242CA2A4"
iso_url = "D:\isos\Win10_Ent_x64_21H2_KMS.iso"
# hyperv_switchname = "packer-external"
switchname = "br0"
autounattend = "answer_files/Windows10_ltsb/autounattend.xml"
shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
disk_type_id = "1"
headless = "true"
http_directory = "./src"
winrm_timeout = "2h"
winrm_use_ntlm = "true"
winrm_use_ssl = "true"
winrm_insecure = "true"
win_temp_dir = "c:\\temp"
keep_registered = "false"
boot_wait = "60s"
# VMWare
tools_upload_flavor = "windows"
vmware_network_adapter_type = "e1000"
vmware_disk_adapter_type  = "scsi"
vmware_guest_os_type = "windows9Server64Guest"

