vm_name = "Windows10_{{isotime \"20060102_1504\"}}.qcow2"
vm_choco_name = "Windows10_choco_{{isotime \"20060102_1504\"}}.qcow2"
nix_output_directory = "/home/libvirt/images/pool/Win10/Win10_{{isotime \"20060102_1504\"}}/"
# nix_choco_output_directory = "/home/libvirt/images/pool/Win10/Win10_choco_{{isotime \"20060102_1504\"}}/"
output_directory = "D:\\Hyperv\\packer\\windows10_21h2"
cpu_num = "6"
disk_size = "80000"
memory = "8192"
iso_checksum = "sha256:5B59D528C1741E682E40145F1A18F05D27363B28D46155909FC95A94AB9EBAAC"
iso_url = "./iso/Windows10_21H2/windows10_202205131436.iso"
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