#!/bin/bash

SUDO_NOPWD=true
LOW_LATENCY=false
SPEEDTEST_VERSION=4.5.5
DOMAIN=5g.lab
#SPEEDTEST_PORT=80
SPEEDTEST_PORT_LIST=(
80
88
)
LOCAL_ETH=ens160
MOUNT_SMB=freenas.5g.lab/share

SCRIPT_PATH=$(dirname $(readlink -f "$0"))

############## System Package (un)install ##############
source "$SCRIPT_PATH/module/system_init.sh"

##############      Speedtest Server      ##############
source "$SCRIPT_PATH/module/speedtest_install.sh"

##############          Nextepc           ##############
source "$SCRIPT_PATH/conf/lte_conf.sh"
source "$SCRIPT_PATH/module/nextepc_install.sh"
