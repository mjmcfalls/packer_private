#!/bin/bash

current_date=$(date "+%Y%m%d%H%M%S")
log_name=packer_build_$current_date.log
vm_name=Windows10_$current_date
output_path=/home/libvirt/images/pool/Win10/Win10_$current_date
packer_path=/home/mmcfalls/dev/packer

export PACKER_LOG="1"
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$log_name"

echo $PACKER_LOG_PATH
echo $vm_name

cd $packer_path

# packer build -timestamp-ui -only 'qemu.Windows_10' -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_parallel.pkr.hcl
# Build OS with no changes
packer build -timestamp-ui -only 'win_iso.qemu.Windows10_iso' -var "keep_registered=true" -var "nix_output_directory=$output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

# Check if VM register if so, poweron, else register and poweron

# Build Base OS
# packer build -timestamp-ui -only 'win_iso.qemu.Windows10_base' -var "keep_registered=true" -var "nix_output_directory=$output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

