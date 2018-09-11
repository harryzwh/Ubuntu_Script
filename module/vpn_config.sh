#!/bin/bash

SCRIPT_PATH=${SCRIPT_PATH-$(dirname $PWD)}

sudo apt-get install -y openvpn
sudo cp "$SCRIPT_PATH/conf/pfsense_vpn.ovpn" /etc/openvpn
sudo cp "$SCRIPT_PATH/conf/vpn_pass.txt" /etc/openvpn

echo -e \
"#!/bin/bash

sudo openvpn /etc/openvpn/pfsense_vpn.ovpn > /dev/null &" \
| sudo tee /usr/bin/run_vpn

sudo chmod +x /usr/bin/run_vpn
