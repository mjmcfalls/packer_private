#!/bin/bash

current_date=$(date "+%Y%m%d%H%M%S")
log_name=packer_build_$current_date.log
vm_name=Windows10_$current_date
bare_output_path=/home/libvirt/images/pool/Win10/Win10_bare_$current_date
base_output_path=/home/libvirt/images/pool/Win10/Win10_base_$current_date
packer_path=/home/mmcfalls/dev/packer

export PACKER_LOG="1"
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$log_name"

echo $PACKER_LOG_PATH
echo $vm_name

cd $packer_path

# packer build -timestamp-ui -only 'qemu.Windows_10' -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_parallel.pkr.hcl
# Build OS with no changes
echo "Starting win_iso.qemu.Windows10_iso - $bare_output_path"
packer build -timestamp-ui -only 'win_iso.qemu.Windows10_iso' -var "keep_registered=true" -var "nix_output_directory=$bare_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

# Check if VM register if so, poweron, else register and poweron
# set -x
vmstate=$(virsh list --all | grep " $vm_name " | awk '{ print $3}')

if [ "$vmstate" == "x" ] || [ "$vmstate" != "running" ]
then
    echo "$vm_name is shut down"
    virsh start "$vm_name"
else
    echo "$vm_name is running!"
fi
# set +x
# Build Base OS
echo "Starting win_base.qemu.Windows10_base - $base_output_path"
packer build -timestamp-ui -only 'win_base.qemu.Windows10_base' -var "keep_registered=true" -var "iso_url=$bare_output_path/$vm_name" -var "nix_output_directory=$base_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

