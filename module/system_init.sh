#!/bin/bash

SUDO_NOPWD=${SUDO_NOPWD-true}
LOW_LATENCY=${LOW_LATENCY-false}
SCRIPT_PATH=${SCRIPT_PATH-$(dirname $PWD)}

if ($SUDO_NOPWD); then
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
fi

if ($LOW_LATENCY); then
sudo apt-get install -y linux-image-`uname -r | cut -d- -f1-2`-lowlatency linux-headers-`uname -r | cut -d- -f1-2`-lowlatency
#sudo apt-get remove -y linux-image-`uname -r | cut -d- -f1-2`-generic linux-headers-`uname -r | cut -d- -f1-2`-generic
fi

if [[ $GDMSESSION == "Lubuntu" ]]; then
sudo apt-get remove -y leafpad abiword* gnumeric* pidgin* transmission* sylpheed* mtpaint alsa* audacious* mplayer guvcview xfburn xpad simple-scan evince* galculator gucharmap gpicview light-locker* blueman xfce4-power-manager* gnome-mplayer usb-creator* update-manager* fcitx* lubuntu-software-center synaptic system-config-printer* hardinfo language-selector* pavucontrol
sudo apt-get autoremove -y
cd /etc/xdg/autostart/
sudo rm -f light-locker.desktop print-applet.desktop pulseaudio.desktop xfce4-power-manager.desktop update-notifier.desktop indicator-sound.desktop 
cd ~
sudo apt-get install -y gedit htop iftop openssh-server
fi

if [[ $(cat /proc/scsi/scsi) =~ "VMware" ]]; then
sudo apt-get install -y open-vm-tools open-vm-tools-desktop 
fi

if [ $MOUNT_SMB ]; then
sudo apt-get -y install cifs-utils
mkdir ~/share_smb
sudo mount -t cifs //$MOUNT_SMB ~/share_smb -o user=smb,passwd=share,dir_mode=0777,file_mode=0777
echo -e "\n//$MOUNT_SMB /home/$USER/share_smb cifs iocharset=utf8,username=smb,password=share,dir_mode=0777,file_mode=0777" | sudo tee -a /etc/fstab
fi

#sudo cp $SCRIPT_PATH/data/Proxy-CA.crt /usr/local/share/ca-certificates/Proxy-CA.crt
#sudo update-ca-certificates

git config --global user.email "harryzwh@gmail.com"
git config --global user.name "harryzwh"


