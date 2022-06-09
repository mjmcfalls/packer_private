#!/bin/bash

current_date=$(date "+%Y%m%d%H%M%S")
log_name=packer_build_$current_date.log
vm_name=Windows10_$current_date
bare_output_path=/home/libvirt/images/pool/Win10/Win10_bare_$current_date
base_output_path=/home/libvirt/images/pool/Win10/Win10_base_$current_date
base_opt_output_path=/home/libvirt/images/pool/Win10/Win10_base_opt_$current_date
baseapp_output_path=/home/libvirt/images/pool/Win10/Win10_baseapp_$current_date
baseapp_opt_output_path=/home/libvirt/images/pool/Win10/Win10_baseapp_opt_$current_date

packer_path=/home/mmcfalls/dev/packer

export PACKER_LOG="1"
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$log_name"

echo $PACKER_LOG_PATH
echo $vm_name

cd $packer_path

# packer build -timestamp-ui -only 'qemu.Windows_10' -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_parallel.pkr.hcl
# Build OS with no changes
echo "Starting win_iso.qemu.Windows10_iso - $bare_output_path"
packer build -timestamp-ui -only 'win_iso.qemu.Windows10_iso' -var "keep_registered=false" -var "nix_output_directory=$bare_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

# Check if VM register if so, poweron, else register and poweron
# set -x
vmstate=$(virsh list --all | grep " $vm_name " | awk '{ print $3}')

if [ "$vmstate" == "x" ] || [ "$vmstate" != "running" ]
then
    echo "$vm_name is shut down"
    # virsh start $vm_name
else
    echo "$vm_name is running!"
fi
# set +x

# Get SHA256 hash of VM
bare_sha=$(sha256sum "$bare_output_path/$vm_name" | cut -d " " -f 1)
# Build Base OS
echo "Starting win_base.qemu.Windows10_base - $base_output_path"
echo "iso_checksum=sha256:$base_sha"
echo "iso_url=$bare_output_path/$vm_name"

packer build -timestamp-ui -only 'win_base.qemu.Windows10_base' -var "keep_registered=false" -var "iso_checksum=sha256:$bare_sha" -var iso_url=$bare_output_path/$vm_name -var "nix_output_directory=$base_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl


base_sha=$(sha256sum "$base_output_path/$vm_name" | cut -d " " -f 1)
# Build Base + Apps1
echo "Starting win_base_apps1.qemu.Windows10_base - $baseapp_output_path"
echo "iso_checksum=sha256:$base_sha"
echo "iso_url=$base_output_path/$vm_name"

packer build -timestamp-ui -only 'win_base_apps1.qemu.Windows10_base' -var "keep_registered=false" -var "iso_checksum=sha256:$base_sha" -var iso_url=$base_output_path/$vm_name -var "nix_output_directory=$baseapp_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

baseapp_sha=$(sha256sum "$baseapp_output_path/$vm_name" | cut -d " " -f 1)

# Optimize VMs
# packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows10_base' -var "keep_registered=false" -var "iso_checksum=sha256:$base_sha" -var iso_url=$base_output_path/$vm_name -var "nix_output_directory=$base_opt_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl
# packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows10_base' -var "keep_registered=false" -var "iso_checksum=sha256:$baseapp_sha" -var iso_url=$baseapp_output_path/$vm_name -var "nix_output_directory=$baseapp_opt_output_path" -var "vm_name=$vm_name" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl
