#!/bin/bash

############## Installation Configuration ##############
OAI_SOURCE=https://gitlab.eurecom.fr/oai/openairinterface5g.git
#OAI_SOURCE=git@github.sydney.edu.au:wzha2887/openairinterface5g.git
OAI_VERSION=3fd2470533e2666bf95dd3204b69c831f6bf6330
LOCAL_ETH=ens192
LOW_LATENCY=true
SUDO_NOPWD=true
CLION=false
MME_ADDR=192.168.56.15
CONF_FILE_LIST=(
x310.conf
b210.conf
)
USRP_ETH=ens160
USRP_IP=192.168.40.1
VPN=true

############## Load LTE configuration  ##############
SCRIPT_PATH=$(dirname $(readlink -f "$0"))
source "$SCRIPT_PATH/conf/lte_conf.sh"

############## System Pakcet (un)install  ##############
source "$SCRIPT_PATH/module/system_init.sh"

##############      OAI installation      ##############
<<EOF
sudo su
echo -n | openssl s_client -showcerts -connect gitlab.eurecom.fr:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> /etc/ssl/certs/ca-certificates.crt
exit
EOF

cd ~
git clone $OAI_SOURCE
cd ~/openairinterface5g
git checkout $OAI_VERSION
source oaienv
cd ~/openairinterface5g/cmake_targets

sudo debconf-set-selections <<< 'wireshark-common wireshark-common/install-setuid boolean false'
sudo apt-get install -y python-pip wireshark
sudo pip install -U setuptools

sudo ./build_oai -I --eNB -x --install-system-files -w USRP

LOCAL_ADDR=$(ifconfig $LOCAL_ETH | awk '{if ( $1 == "inet" && $3 ~ /^Bcast/) print $2}' | awk -F: '{print $2}')

CONF_FILE_TARGET=~/openairinterface5g/cmake_targets/lte_build_oai/build
for CONF_FILE in ${CONF_FILE_LIST[@]}; do
sudo cp "$SCRIPT_PATH/data/$CONF_FILE" "$CONF_FILE_TARGET/$CONF_FILE"
sudo chmod 777 "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/mobile_country_code[0-9 =\"]\+/mobile_country_code = \"$MCC_ID\"/" "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/mobile_network_code[0-9 =\"]\+/mobile_network_code = \"$MNC_ID\"/" "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/tracking_area_code[0-9 =\"]\+/tracking_area_code = \"$TAC_ID\"/" "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/ipv4 *=[0-9 \".]\+/ipv4       = \"$MME_ADDR\"/" "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/ENB_IPV4_ADDRESS_FOR_S1_MME[0-9 =\".\/]\+/ENB_IPV4_ADDRESS_FOR_S1_MME = \"$LOCAL_ADDR\/24\"/" "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/ENB_IPV4_ADDRESS_FOR_S1U[0-9 =\".\/]\+/ENB_IPV4_ADDRESS_FOR_S1U = \"$LOCAL_ADDR\/24\"/" "$CONF_FILE_TARGET/$CONF_FILE"
sudo sed -i "s/eth[0-9]/$LOCAL_ETH/" "$CONF_FILE_TARGET/$CONF_FILE"
done

##############   USRP ETH Configuration  ##############
echo "@${USER}    -    rtprio    99" | sudo tee -a /etc/security/limits.conf
source "$SCRIPT_PATH/module/usrp_eth_config.sh"

if ($CLION); then
cd ~/openairinterface5g
cat oaienv >> ~/.profile
sed -i "s#\$(pwd)#$(pwd)#" ~/.profile
sudo chmod 777 ~/openairinterface5g/cmake_targets/lte_build_oai/
source "$SCRIPT_PATH/module/clion_install.sh"
fi

if ($VPN); then
source "$SCRIPT_PATH/module/vpn_config.sh"
fi

