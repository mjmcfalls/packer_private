#! /bin/bash
export PACKER_LOG=1
export PACKER_LOG_PATH="/home/mmcfalls/packer_logs.log"


packer build -force -var-file ~/dev/packer/vars/Windows10/Windows10_vars.json ~/dev/packer/Windows10_qemu.pkr.hcl