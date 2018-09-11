#!/bin/bash

sudo apt-get install -y apache2 php libapache2-mod-php php-mcrypt

if [[ $(cat /etc/apache2/apache2.conf ) =~ "KeepAlive Off" ]]; then
sudo sed -i "s/KeepAlive Off/KeepAlive On/" /etc/apache2/apache2.conf 
fi
sudo sed -i "s/max_execution_time *= *[0-9]\+/max_execution_time = 90/" /etc/php/7.0/apache2/php.ini 
sudo sed -i "s/max_input_time *= *[0-9]\+/max_input_time = 90/" /etc/php/7.0/apache2/php.ini 
sudo sed -i "s/memory_limit *= *[0-9]\+M/memory_limit = 128M/" /etc/php/7.0/apache2/php.ini 
sudo sed -i "s/post_max_size *= *[0-9]\+M/post_max_size = 50M/" /etc/php/7.0/apache2/php.ini 
sudo sed -i "s/upload_max_filesize *= *[0-9]\+M/upload_max_filesize = 50M/" /etc/php/7.0/apache2/php.ini 

echo -e "net.core.rmem_max=16777216" | sudo tee -a /etc/sysctl.conf
echo -e "net.core.wmem_max=16777216" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.tcp_window_scaling=1" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.tcp_rmem=4096 87380 16777216" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.tcp_wmem=2096 65535 16777216" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.tcp_mem=98304 131072 196608" | sudo tee -a /etc/sysctl.conf
echo -e "net.core.netdev_max_backlog=250000" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.tcp_timestamps=1" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.ip_local_port_range=1025 61000" | sudo tee -a /etc/sysctl.conf
echo -e "net.ipv4.tcp_congestion_control=htcp" | sudo tee -a /etc/sysctl.conf

sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_window_scaling=1
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl -w net.ipv4.tcp_wmem="2096 65535 16777216"
sudo sysctl -w net.ipv4.tcp_mem="98304 131072 196608"
sudo sysctl -w net.core.netdev_max_backlog=250000
sudo sysctl -w net.ipv4.tcp_timestamps=1
sudo sysctl -w net.ipv4.ip_local_port_range="1025 61000"
sudo sysctl -w net.ipv4.tcp_congestion_control=htcp

cd ~
sudo chmod 777 /var/www/
cd /var/www
#git clone https://github.com/adolfintel/speedtest
git clone https://github.com/harryzwh/speedtest
cd /var/www/speedtest
#git checkout $SPEEDTEST_VERSION
#cp example-gauges.html index.html

for SPEEDTEST_PORT in ${SPEEDTEST_PORT_LIST[@]}; do
echo -e \
"<VirtualHost *:$SPEEDTEST_PORT>

        ServerAdmin admin@$DOMAIN
        ServerName speedtest.$DOMAIN
        DocumentRoot /var/www/speedtest

        <Directory /var/www/speedtest>
           Options FollowSymLinks
           AllowOverride All
           Require all granted
        </Directory>

    ErrorLog \${APACHE_LOG_DIR}/speedtest_error.log
    CustomLog \${APACHE_LOG_DIR}/speedtest_access.log combined

</VirtualHost>" \
| sudo tee "/etc/apache2/sites-available/speedtest_${SPEEDTEST_PORT}.conf"

if [[ ! $(grep -w "Listen $SPEEDTEST_PORT" /etc/apache2/ports.conf) ]]; then
echo -e "Listen $SPEEDTEST_PORT" | sudo tee -a /etc/apache2/ports.conf
fi
sudo a2ensite "speedtest_${SPEEDTEST_PORT}"
done

sudo systemctl restart apache2
