#!/bin/bash

current_date=$(date "+%Y%m%d%H%M%S")
log_name=packer_build_$current_date.log
packer_path=/home/mmcfalls/dev/packer

# Packer variable files
os_vars=vars/Server2022/Server2022.pkrvars.hcl
secret_vars=secrets/secrets.pkrvars.hcl
build_file=Windows10_stages_homelab.pkr.hcl
app_vars=vars/Windows_App_Vars.pkrvars.hcl

os_name=Server2022
vm_name=$os_name-$current_date

bare_output_path=/home/libvirt/images/pool/$os_name/$os_name-bare-$current_date
base_output_path=/home/libvirt/images/pool/$os_name/$os_name-base-$current_date
base_opt_output_path=/home/libvirt/images/pool/$os_name/$os_name-base-opt-$current_date
baseapp_output_path=/home/libvirt/images/pool/$os_name/$os_name-baseapp-$current_date
baseapp_opt_output_path=/home/libvirt/images/pool/$os_name/$os_name-baseapp-opt-$current_date

baseapptwo_output_path=/home/libvirt/images/pool/$os_name/$os_name-baseapptwo-$current_date
baseapptwo_opt_output_path=/home/libvirt/images/pool/$os_name/$os_name-baseapptwo-opt-$current_date

# Virt information
virt_bridge=br0
os_variant=win10
declare -i virt_cpu=6
declare -i virt_memory=8192

# os_vars=vars/Windows10/Windows10.pkrvars.hcl
# secret_vars=secrets/secrets.pkrvars.hcl
# build_file=Windows10_stages_homelab.pkr.hcl


export PACKER_LOG="1"
export LIBVIRT_DEFAULT_URI="qemu:///system"

# echo $vm_name

cd $packer_path

# packer build -timestamp-ui -only 'qemu.Windows_10' -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_parallel.pkr.hcl
# Build OS with no changes
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-bare-$current_date"

echo "Starting win_iso.qemu.win_iso"
echo "Path: $bare_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"

packer build -timestamp-ui -only 'win_iso.qemu.win_iso' -var "keep_registered=false" -var "nix_output_directory=$bare_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file

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
echo "Generating SHA256 checksum for $bare_output_path/$vm_name"
bare_sha=$(sha256sum "$bare_output_path/$vm_name" | cut -d " " -f 1)

# Build Base OS
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-base-$current_date"
echo "Starting win_base.qemu.Windows_base"
echo "iso_checksum=sha256:$bare_sha"
echo "iso_url=$bare_output_path/$vm_name"
echo "Path: $base_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"

echo "packer build -timestamp-ui -only 'win_base.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$bare_sha" -var iso_url=$bare_output_path/$vm_name -var "nix_output_directory=$base_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file"
packer build -timestamp-ui -only 'win_base.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$bare_sha" -var iso_url=$bare_output_path/$vm_name -var "nix_output_directory=$base_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file

echo "Generating SHA256 checksum for $base_output_path/$vm_name"
base_sha=$(sha256sum "$base_output_path/$vm_name" | cut -d " " -f 1)

# Build Base + Apps1
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-baseapp-$current_date"
echo "Starting win_base_apps1.qemu.Windows_base"
echo "iso_checksum=sha256:$base_sha"
echo "iso_url=$base_output_path/$vm_name"
echo "Path: $baseapp_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"

packer build -timestamp-ui -only 'win_base_apps1.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$base_sha" -var iso_url=$base_output_path/$vm_name -var "nix_output_directory=$baseapp_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file

echo "Generating SHA256 checksum for $baseapp_output_path/$vm_name"
baseapp_sha=$(sha256sum "$baseapp_output_path/$vm_name" | cut -d " " -f 1)

echo "Generating SHA256 checksum for $base_output_path/$vm_name"

# Build Base + Apps2
echo "Starting Starting win_base_apps2.qemu.Windows_base"
echo "iso_checksum=sha256:$base_sha"
echo "iso_url=$base_output_path/$vm_name"
echo "Path: $baseapptwo_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"

export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-baseapptwo-$current_date"
packer build -timestamp-ui -only 'win_base_apps2.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$base_sha" -var iso_url=$base_output_path/$vm_name -var "nix_output_directory=$baseapptwo_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file

echo "Generating SHA256 checksum for $baseapptwo_output_path/$vm_name"
baseapptwo_sha=$(sha256sum "$baseapptwo_output_path/$vm_name" | cut -d " " -f 1)

# Optimize VMs
# Optimize base
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-base_opt-$current_date"

echo "Starting win_base_optimize.qemu.Windows_base"
echo "iso_checksum=sha256:$base_sha"
echo "iso_url=$base_output_path/$vm_name"
echo "Path: $base_opt_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"

packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$base_sha" -var iso_url=$base_output_path/$vm_name -var "nix_output_directory=$base_opt_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file


# Optimize Base app
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-baseapp-opt-$current_date"

echo "Starting win_base_optimize.qemu.Windows_base"
echo "iso_checksum=sha256:$baseapp_sha"
echo "iso_url=$baseapp_output_path/$vm_name"
echo "Path: $baseapp_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"

packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$baseapp_sha" -var iso_url=$baseapp_output_path/$vm_name -var "nix_output_directory=$baseapp_opt_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file

# Optimize baseapptwo
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$os_name-baseapptwo-opt-$current_date"
echo "Starting win_base_optimize.qemu.Windows_base"
echo "iso_checksum=sha256:$baseapptwo_sha"
echo "iso_url=$baseapptwo_output_path/$vm_name"
echo "Path: $baseapptwo_output_path"
echo "VM Name: $vm_name"
echo "App Vars File: $app_vars"
echo "OS File: $os_vars"
echo "Secrets File: $secret_vars"
echo "Build File: $build_file"
echo "Logs: $PACKER_LOG_PATH"


packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$baseapptwo_sha" -var iso_url=$baseapptwo_output_path/$vm_name -var "nix_output_directory=$baseapptwo_opt_output_path" -var "vm_name=$vm_name" -var-file $app_vars -var-file $os_vars -var-file $secret_vars $build_file

# 
# Adding new VMs to KVM
# 

echo "Starting Virt-install"
# echo "virt-install --name "$os_name_base_$current_date" --memory 8192 --vcpus 6 --disk bus=virtio,path=$base_output_path/$vm_name --network bridge:br0 --import --os-variant win10"
# virt-install --name "$os_name_base_$current_date" --memory 8192 --vcpus 6 --disk bus=virtio,path=$base_output_path/$vm_name --network bridge:br0 --import --os-variant win10
# virt-install --name "$os_name_baseapp_$current_date" --memory 8192 --vcpus 6 --disk "$baseapp_output_path/$vm_name" --import --os-variant win10

echo "virt-install --name $os_name-base-opt-$current_date --memory $virt_memory --vcpus virt_cpu --disk bus=virtio,path=$base_opt_output_path/$vm_name --network bridge:$virt_bridge --import --os-variant $os_variant --noautoconsole"
virt-install --name $os_name-base-opt-$current_date --memory $virt_memory --vcpus $virt_cpu --disk bus=virtio,path=$base_opt_output_path/$vm_name --network bridge:$virt_bridge --import --os-variant $os_variant --noautoconsole

echo "virt-install --name $os_name-baseapp-opt-$current_date --memory $virt_memory --vcpus virt_cpu --disk bus=virtio,path=$baseapp_opt_output_path/$vm_name --network bridge:$virt_bridge  --import --os-variant $os_variant --noautoconsole"
virt-install --name $os_name-baseapp-opt-$current_date --memory $virt_memory --vcpus virt_cpu --disk bus=virtio,path=$baseapp_opt_output_path/$vm_name --network bridge:$virt_bridge --import --os-variant $os_variant --noautoconsole

echo "virt-install --name $os_name-baseapptwo-opt-$current_date --memory $virt_memory --vcpus virt_cpu --disk bus=virtio,path=$baseapptwo_opt_output_path/$vm_name --network bridge:$virt_bridge  --import --os-variant $os_variant --noautoconsole"
virt-install --name $os_name-baseapptwo-opt-$current_date --memory $virt_memory --vcpus virt_cpu --disk bus=virtio,path=$baseapptwo_opt_output_path/$vm_name --network bridge:$virt_bridge  --import --os-variant $os_variant --noautoconsole


echo "Adding SCSI Controller to $os_name-base-opt-$current_date"
virsh attach-device --config $os_name-base-opt-$current_date /home/mmcfalls/dev/packer/src/scripts/kvm/scsi-controller.xml

echo "Adding SCSI Controller to $os_name-baseapp-opt-$current_date" 
virsh attach-device --config $os_name-baseapp-opt-$current_date /home/mmcfalls/dev/packer/src/scripts/kvm/scsi-controller.xml

echo "Starting $os_name-baseapp-opt-$current_date" 
virsh start $os_name-baseapp-opt-$current_date

echo "Starting $os_name-base-opt-$current_date"
virsh start $os_name-base-opt-$current_date

echo "Adding Bluray Drive to $os_name-baseapp-opt-$current_date" 
virsh attach-device --config $os_name-baseapp-opt-$current_date /home/mmcfalls/dev/packer/src/scripts/kvm/bluray-drive.xml