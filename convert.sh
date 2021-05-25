#!/bin/bash

#This script will automate adding all of our additions and changes on top of a vanilla intallation of Kali Linux.
#It has not been tested with Parrot.

function pause(){
    read -p "$*"
}

#Root check!
if [ "$EUID" -ne 0 ]
then
    whiptail --backtitle "Pentest Conversion Script" --title "Welcome" --msgbox "You are not signed in as root.  This script will prompt for sudo as needed." 7 79
fi

whiptail --backtitle "Pentest Conversion Script" --title "Welcome" --msgbox "This script will add our changes on top of your Kali installation." 7 70

REPO=$(whiptail --backtitle "Pentest Conversion Script" --title "Repository" --menu "Which repository are you going to use?" 10 60 2 \
    "default" "The distribution's default repository" \
    "local" "A repository hosted on your local network" 3>&1 1>&2 2>&3)

if [ $REPO == "local" ];
then
    REPO=$(whiptail --backtitle "Pentest Conversion Script" --title "Local Repository" --inputbox "What is the IP address of your local repository?" \
    10 60 3>&1 1>&2 2>&3)
fi

if [ $REPO != "default" ];
then
	sudo cp /etc/apt/sources.list /etc/apt/sources.list.original
    sudo sed -i "s|http.kali.org|$REPO|g" /etc/apt/sources.list
fi

sudo apt update
sudo apt upgrade -y
#****************************************
#****************************************
#****************************************
#Install Core Software Components
#****************************************
#****************************************
#System utilities
sudo apt install -y apt-file cockpit dkms exfat-fuse exfat-utils fuse
sudo apt install -y guake htop libpam-google-authenticator ncdu nemo
sudo apt install -y powershell pptp-linux xrdp xserver-xorg-input-all xinput

#VM stuff
sudo apt install -y open-vm-tools-desktop spice-vdagent xserver-xorg-video-qxl
sudo apt install -y xserver-xorg-video-vmware

#Printing
sudo apt install -y cups cups-client foomatic-db

#Firewalls
sudo apt install -y firewalldfirewall-config

#Privacy tools
sudo apt install -y bleachbit proxychains scrub tor

#Office/productivity tools
sudo apt install -y audacity cherrytree gedit gedit-plugins gimp 
sudo apt install -y libreoffice screenfetch vlc

#Software development
sudo apt install -y build-essential cmake git git-lfs linux-headers-amd64
sudo apt install -y ninja-build pkg-config

#Fun stuff
sudo apt install -y cmatrix gnome-chess lolcat

#Themes
sudo apt install -y arc-theme gnome-icon-theme

#Archive utilities
sudo apt install -y file-roller lzip lzop rpm2cpio rzip sharutils
sudo apt install -y unace unalz unar

wget -O ../build/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
wget -O ../build/slack.deb "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb"
rm ./build/.gitignore
sudo dpkg -i ./build/
#**************************************
#**************************************
#Update file System
#**************************************
#**************************************
sudo rsync -HAXav ./filesystem/ /
if [ "$EUID" -ne 0 ]
then
    rsync -av /etc/skel/ $HOME
fi
#*************************************
#*************************************
#Configure Services
#*************************************
#************************************
#Populate root's home folder from /etc/skel
cp -rv /etc/skel/. /root/

#Time to git stuff...
cd /root/
git clone https://github.com/Veil-Framework/Veil.git /etc//opt/Veil
git clone https://github.com/leebaird/discover.git /etc/opt/discover
git clone https://github.com/trustedsec/ptf /etc/opt/ptf

#Enable/disable our desired services
systemctl enable ssh
systemctl enable cups
systemctl enable apache2
systemctl enable mysql
systemctl enable postgresql
systemctl disable tor
systemctl disable cockpit.socket
systemctl enable xrdp
systemctl disable firewalld

#Allow VLC to run as root
sed -i 's/geteuid/getppid/' /usr/bin/vlc

#Install VS Code
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/vscodium-archive-keyring.gpg] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list.d/vscodium.list
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/vscodium-archive-keyring.gpg
sudo apt update && sudo apt install codium -y

#Install VS Code extensions
#codium --install-extension dbaeumer.vscode-eslint --user-data-dir=~/.vscode-oss
#codium --install-extension ecmel.vscode-html-css --user-data-dir=~/.vscode-oss
#codium --install-extension hookyqr.beautify --user-data-dir=~/.vscode-oss
#codium --install-extension ms-azuretools.vscode-docker --user-data-dir=~/.vscode-oss
#codium --install-extension ms-python.python --user-data-dir=~/.vscode-oss
#codium --install-extension ms-vscode.cpptools --user-data-dir=~/.vscode-oss
#codium --install-extension ms-vscode.csharp --user-data-dir=~/.vscode-oss
#codium --install-extension ms-vscode.go --user-data-dir=~/.vscode-oss
#codium --install-extension ms-vscode.powershell --user-data-dir=~/.vscode-oss
#codium --install-extension rebornix.ruby --user-data-dir=~/.vscode-oss
#codium --install-extension zignd.html-css-class-completion --user-data-dir=~/.vscode-oss


if (whiptail --backtitle "Pentest Conversion Script" --title "Complete" --yesno "The script is now complete.  A reboot is recommended.\nWould you like to reboot now?" 10 60)
then
    whiptail --backtitle "Pentest Conversion Script" --title "Rebooting!" --msgbox "Thank you for using this script.  Enjoy your new Kali!" 8 60
    sudo reboot
else
    whiptail --backtitle "Pentest Conversion Script" --title "Finished!" --msgbox "Thank you for using this script.  Enjoy your new Kali!" 8 30
    exit 1
fi
