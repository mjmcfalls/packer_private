#!/bin/bash

current_date=$(date "+%Y%m%d%H%M%S")
file_name=packer_build_rhel8_$current_date.log

export PACKER_LOG="1"
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$file_name"

cd /home/mmcfalls/dev/packer
/usr/bin/packer build -force -var-file vars/rhel8/rhel8.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl rhel8_qemu.pkr.hcl