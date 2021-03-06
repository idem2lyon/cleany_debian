#!/bin/bash
# Created by idem2lyon <idem@geekandmore.fr>
# DESCRIPTION	: The main part of Uris
#---------------------------------------------------------------------------
#    Copyright (C) idem2lyon 2015
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------
# Run this script after your first boot with archlinux (as root)
# Variables
#----------------------------------------------------------------------------
# Defaults
uris=`pwd`
defsleep=0;
uisleep=2;
r='\033[91m'; g='\033[92m'; w='\033[0m' # Colours


#---------------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------------
thank() {
  echo ""
  echo "Thank You"
  echo "By idem2lyon"
  echo "Please, visit http://geekandmore.fr"
  sleep 1.5
  clear
  exit 0
}

check_root() { 
 echo -en "Checking if user is running as \033[91mROOT\033[0m"; sleep 0.5
 [[ "$UID" != 0 ]] && { echo "Please run as root!"; exit 1; }
  echo "User running as root!!"
  sleep $defsleep
}

check_net() { 
  echo -en "Checking for internet connection"; sleep 0.2
  for i in $(seq 3); do echo -n '.'; sleep 0.8; done  # waiting time
  ping -c 3 8.8.8.8 &>/dev/null && { echo -e "${G}Success!\n$W"; return \
    0; } || { echo -e "${R}Failure! Please connect to the Internet first!\n$W" >&2;
    return 1; }
}

title() { echo -e "\033[92m\
 _   _      _                                                                                                                 
| | | |_ __(_)___     The Ultimate                                                                                                        
| | | | '__| / __|        Raspberry                                                                                                    
| |_| | |  | \__ \            Installation                                                                                                
 \___/|_|  |_|___/                Scripts\n\033[m"; return 0

echo ""
echo "##############################################################"
echo "##   Welcome to the ...                                     ##"
echo "##   Ultimate Rpi Installation Scripts v1.0                 ##"
echo "##   -- By idem2lyon                                        ##"
echo "##   Please, visit http://geekandmore.fr                    ##"
echo "##############################################################"
echo "  "
sleep 1  
}

yesorno() {                                                                                                                   
  while [ 1 -eq 1 ]                                                                                                     
  do                                                                                                                    
    echo  "$1 "                                                                                                   
    read answer                                                                                                   
    answer=$(echo $answer | tr '[a-z]' '[A-Z]')                                                                   
    [[ $answer == [Y] ]] && { return 0; }                                                                         
    [[ $answer == [N] ]] && { return 1; }                                                                         
  done                                                                                                                  
}                                                                                                                             

conf_vim() {
  echo "Install vim"
  aptitude install vim vim-nox
  echo "Update default editor"
  update-alternatives --set editor /usr/bin/vim.nox
  echo "Configuring vim"
  cp /etc/vim/vimrc /etc/vimrc.backup
  cp ${uris}/config/vimrc /etc/vim/vimrc 
}

hname() {  
  read -p "Enter the new hostname: " hn 
  echo $hn > /etc/hostname
  hostname -F /etc/hostname
  /etc/init.d/hostname.sh start
  echo "Your new hostname is:" $(hostname)
  myhostname=`hostname -s`
}

set_locale() {	
  echo "Configuring locale"
  echo "fr_FR ISO-8859-1
  fr_FR.UTF-8 UTF-8" > /etc/locale.gen
  echo "LANG=\"fr_FR.UTF-8\"" > /etc/default/locale
  echo"" > /etc/environment
  /usr/sbin/locale-gen
  echo "Locales configured"
}

motd() {
  echo "Fancy motd"
  chown root:root ${uris}/config/motd.sh
  chmod +x ${uris}/config/motd.sh
  mv /etc/motd /etc/motd_backup
  cp ${uris}/config/motd.sh /etc/profile.d/
  echo "motd added"
}

timezone() {
  rm -rf /var/lib/apt/lists/* 
  echo "Europe/Berlin" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
}

security() {
  # Create a user group staff
  
  # Configure SSH & securiy
  /bin/sed -i -e 's/PermitRootLogin without-password/PermitRootLogin no\nAllowGroups staff/' /etc/ssh/sshd_config
  /bin/sed -i -e 's/^PrintLastLog yes*/PrintLastLog no' /etc/ssh/sshd_config
  /bin/sed -i -e 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
  service ssh restart

  # Configure SUDO
    echo " ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)
}

bashing() {
  # Configure BASH
  echo 'alias ls="ls -lah --color=auto"' >> /etc/bash.bashrc
}

update_arch() {
  #yesorno "Do you want to update Arch? [Y/n]" &&
  echo "Updating Arch Linux to its Latest Release..."
  apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y autoremove
  #yesorno "You need to reboot to apply changes. Do you want to doit now? [Y/n]" && reboot
}

install_pkg() { # My default Installation
  #yesorno "Do you want to install packages? [Y/n]" &&
  echo "Updating $(grep "^ID=" /etc/*-release|cut -d= -f2)..."
  xargs -a <(awk '/^\s*[^#]/' "mypackages") -r -- sudo apt-get install -y
}

partm() {
  $rpi_aui/./main.sh title
  echo " Lets Utilize full size of the Memory Card "
  echo "Partition Manager"
  echo " "
  echo " Commands "
  echo " "
  echo "d - delete a partition"
  echo "l - list known partition types"
  echo "n - add a new partition"
  echo "p - print the partition table"
  echo "t - change a partition type"
  echo "v - verify the partition table"
  echo " "
  #fdisk /dev/mmcblk0
}

###################################
###################################
###################################
###################################
#^ validé
###################################
###################################
###################################
###################################


create_SSL() {
  # Configuration Certificate SSL RUN openssl genrsa -out ${myhostname}.key 2048
  openssl req \
        -new \
        -subj "/C=FR/ST=France/L=Lyon/O=jeedom/OU=JE/CN=jeedom" \
        -key jeedom.key \
        -out jeedom.csr && \
  openssl x509 -req -days 9999 -in ${myhostname}.csr -signkey ${myhostname}.key -out ${myhostname}.crt
}

tuning_php() {
  # modification de la configuration PHP pour un temps d'exécution allongé et le traitement de fichiers lourds RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php5/fpm/php.ini
  sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 1G/g" /etc/php5/fpm/php.ini
  sed -i "s/post_max_size = 8M/post_max_size = 1G/g" /etc/php5/fpm/php.ini
}













function menu() { # User Interface
  W="$r**$w"; echo -e "Press$r q$w to quit
  $W --> To do (Be Cautious)
########################################################
1. Ping Check                  c. Command Pi v1.0 $W
2. Arch Linux Update           d. Display Pi v1.5
3. Partition Manager $W        o. OverClocking Pi v2.0
4. User Management             u. Utility Pi v2.0
5. Change Root Password        l. LXDE on LAN v1.0
6. Change Locale $W            p. Install pi4j v1.0
7. Hostname                    r. Resize Pi v1.1
8. Resize root file system $W  m. User Pi v2.0
9. Default Installation        t. Change timezone
10.Update AUI $W               l. Change locale
99.Changelog $W                v. View Credits
########################################################"
  read -p "Select an option: " opt
  case $opt in
    1) check_net; sleep 1 ;;

    2)yesorno "Do you want to update Arch? [Y/n]" &&
      echo "Updating Arch Linux to its Latest Release..."
      apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y autoremove
      pacman -Syu --noconfirm && echo " You have the latest Arch ;) "
      yesorno "You nedd to reboot to apply changes. Do you want to doit now? [Y/n]" && reboot
      ;;

    3) $rpi_aui/./yn.sh "You are $rWARNED$w not to manage Partitions. Are you sure? [y/N]" || ui # Too long! -> Need to shorten
      partm
      read s
      ui
      ;;

    4) echo "User Management"; echo
    $rpi_aui/./userm.sh; ui    # Return to user interface
    ;;

    5) $rpi_aui/./yn.sh "Do you want to change $r\Root$w Password? [y/N]" && passwd;;  # Too long! -> Need to shorten

    6) $rpi_aui/./yn.sh "Do you want to change the Locale? [y/N]" || ui
    echo -n "Default Locale: "
    sleep $defsleep
    grep -v ^# /etc/locale.gen
    read s
    ui
    ;;

    7) echo "Your current hostname is:" $(hostname)
      $rpi_aui/./yn.sh "Do you wish to change the hostname? [y/N]" || ui
      hname
      ;;

    8) $rpi_aui/./resize.sh;;

    9) echo "Default Installation: "; $rpi_aui/main.sh net; defins
      $rpi_aui/oc.sh
      $rpi_aui/yn.sh "Do you want to change $r\Root$w Password? [y/N]" &&
        passwd
      $rpi_aui/util.sh
      hname
      read s
      ui
      ;;

    10) echo "Checking for AUI Updates . . "; update
    echo "Update Complete!"
    sleep 1
    ui
    ;;

    c) echo "You have selected Command Pi"
    sleep $uisleep
    $rpi_aui/./command.sh
    ;;

    d) echo " You have selected Display Pi "
    sleep $uisleep
    $rpi_aui/./disp.sh
    ui
    ;;

    o) $rpi_aui/yn.sh "Do you want to OverClock PI? [y/N]" || ui
      sleep $uisleep && $rpi_aui/./oc.sh
      ;;

    u) echo "You have selected Utility Pi "
    sleep $uisleep
    $rpi_aui/./util.sh
    ;;

    l) echo "You have selected LXDE on LAN "
    sleep $uisleep
    $rpi_aui/./lan_lxde.sh
    ui
    ;;

    p) echo "You have selected pi4j "
    sleep $uisleep
    $rpi_aui/./pi4j.sh
    ui
    ;;

    r) echo "You have selected Resize Pi "
      sleep $uisleep
      $rpi_aui/./resize.sh
      ui
      ;;

    m) echo "You have selected User Pi "
      sleep $uisleep
      $rpi_aui/./userm.sh
      ui
      ;;

    t) [[ ! -f /etc/localtime ]] && echo "You have not set your timezone." ||
    echo "Your current localtime:" $(basename `realpath /etc/localtime`)
    $rpi_aui/./yn.sh "Do you wish to set your localtime? [y/N]" || ui
    if hash python2 2>/dev/null; then
      echo "Python2 is installed."
    elif hash python3 2>/dev/null; then
      # Translate to python3 if python3 is installed
      echo "Python3 in installed."
      sed -i 's/python2/python3/g; s/raw_input/input/g' $rpi_aui/timezone.py
    else echo "Python is not installed... installing python2."
      pacman -S --needed --noconfirm python2
    fi
    $rpi_aui/./timezone.py # Run timezone.py
    ;;

    v) less $aui_doc/AUTHORS ;;

    q) $rpi_aui/./main.sh title thank; exit ;;
  esac
}


#----------------------------------------------------------------------------
# Main - forever in ui loop
#----------------------------------------------------------------------------
chmod +x $rpi_aui/*; $rpi_aui/main.sh root && while : ; do ui; done || exit 1
