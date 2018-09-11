#!/bin/bash

if [ $USRP_ETH ] && [ $USRP_IP ] && [[ $(ifconfig) =~ $USRP_ETH ]]; then
echo -e "net.core.rmem_max=33554432" | sudo tee -a /etc/sysctl.conf
echo -e "net.core.wmem_max=33554432" | sudo tee -a /etc/sysctl.conf
sudo sysctl -w net.core.rmem_max=33554432
sudo sysctl -w net.core.wmem_max=33554432
sudo ifconfig $USRP_ETH $USRP_IP/24 broadcast $(echo $USRP_IP | cut -f 1,2,3 -d ".").255 mtu 9000
echo -e "\nauto $USRP_ETH" | sudo tee -a /etc/network/interfaces
echo -e "iface $USRP_ETH inet static" | sudo tee -a /etc/network/interfaces
echo -e "\taddress $USRP_IP" | sudo tee -a /etc/network/interfaces
echo -e "\tnetmask 255.255.255.0" | sudo tee -a /etc/network/interfaces
echo -e "\tbroadcast $(echo $USRP_IP | cut -f 1,2,3 -d ".").255" | sudo tee -a /etc/network/interfaces
echo -e "\tmtu 9000" | sudo tee -a /etc/network/interfaces
fi
