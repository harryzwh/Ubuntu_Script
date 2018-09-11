#!/bin/bash

sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:acetcom/nextepc
sudo apt-get update
sudo apt-get -y install nextepc

sudo apt-get -y install curl
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sL http://nextepc.org/static/webui/install | sudo -E bash -
#sudo -E "$SCRIPT_PATH/module/nextepc_gui_install.sh"

sudo debconf-set-selections <<< "wireshark-common wireshark-common/install-setuid boolean false"
sudo apt-get install -y wireshark

LOCAL_ADDR=$(ifconfig $LOCAL_ETH | awk '{if ( $1 == "inet" && $3 ~ /^Bcast/) print $2}' | awk -F: '{print $2}')
sudo cp /etc/nextepc/mme.conf /etc/nextepc/mme.conf.bak
sudo cp /etc/nextepc/sgw.conf /etc/nextepc/sgw.conf.bak
sudo cp /etc/nextepc/pgw.conf /etc/nextepc/pgw.conf.bak
sudo sed -i "s/^[ ]*s1ap:$/    s1ap:\n      addr: $LOCAL_ADDR/" /etc/nextepc/mme.conf 
sudo sed -i "s/mcc:[0-9 ]\+/mcc: $MCC_ID/" /etc/nextepc/mme.conf 
sudo sed -i "s/mnc:[0-9 ]\+/mnc: $MNC_ID/" /etc/nextepc/mme.conf 
sudo sed -i "s/tac:[0-9 ]\+/tac: $TAC_ID/" /etc/nextepc/mme.conf 
sudo sed -i "s/^[ ]*gtpu:$/    gtpu:\n      addr:$LOCAL_ADDR/" /etc/nextepc/sgw.conf 
#sudo sed -i "s#addr: 45.45.0.1/16#addr: $PGW_SUBNET_FH#" /etc/nextepc/pgw.conf 
sudo sed -i "s/8.8.8.8/$DNS_1/" /etc/nextepc/pgw.conf
sudo sed -i "s/8.8.4.4/$DNS_2/" /etc/nextepc/pgw.conf

#sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
#sudo iptables -t nat -A POSTROUTING -o $LOCAL_ETH -j MASQUERADE
#sudo iptables -I INPUT -i pgwtun -j ACCEPT

sudo sysctl -w net.ipv4.ip_forward=1
echo -e "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -o $LOCAL_ETH -j MASQUERADE
sudo iptables -I INPUT -i pgwtun -j ACCEPT
sudo iptables-save | sudo tee /etc/iptables-rules
echo -e "pre-up iptables-restore < /etc/iptables-rules" | sudo tee -a /etc/network/interfaces

sudo systemctl restart nextepc-hssd
sudo systemctl restart nextepc-mmed
sudo systemctl restart nextepc-sgwd
sudo systemctl restart nextepc-pgwd
sudo systemctl restart nextepc-pcrfd

echo -e \
"<VirtualHost *:80>

    ServerAdmin admin@$DOMAIN
    ServerName nextepc.$DOMAIN

    ProxyPreserveHost On
    ProxyRequests off
    ProxyPass / http://127.0.0.1:3000/
    ProxyPassReverse / http://127.0.0.1:3000/

</VirtualHost>" \
| sudo tee /etc/apache2/sites-available/nextepc.conf
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
sudo a2ensite nextepc
sudo systemctl restart apache2
