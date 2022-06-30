#!/bin/bash

current_date=$(date "+%Y%m%d%H%M%S")
file_name=packer_build_$current_date.log

export PACKER_LOG="1"
export PACKER_LOG_PATH="/home/mmcfalls/dev/logs/$file_name"
