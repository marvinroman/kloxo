#!/bin/sh

#    Kloxo-MR - Hosting Control Panel
#
#    Copyright (C) 2013 - MRatWork
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# MRatWork - Kloxo-MR dev Installer
#
# Version: 1.0 (2013-01-11 - by Mustafa Ramadhan <mustafa@bigraf.com>)
#

APP_NAME='Kloxo-MR'

echo
echo "*** Ready to begin $APP_NAME install. ***"
echo
echo "- Note some file downloads may not show a progress bar so please,"
echo "  do not interrupt the process."
echo
echo "- When it's finished, you will be presented with a welcome message and"
echo "  further instructions."
echo
read -n 1 -p "Press any key to continue ..."
echo

if [ "$1" != "-y" ]; then
	echo
	echo "Select Master/Slave for Kloxo-MR - choose Master for single server"
	PS3='- Please enter your choice: '
	options=("Master" "Slave")
	select opt in "${options[@]}" "Quit"; do 
		case $opt in
			"Master")
				APP_TYPE='master'
				break
				;;
			"Slave")
				APP_TYPE='slave'
				break
				;;
   			"Quit")
				exit
				;;
				*) echo "  * Invalid option!";;
		esac
	done
else
	APP_TYPE='master'
fi

SELINUX_CHECK=/usr/sbin/selinuxenabled
SELINUX_CFG=/etc/selinux/config
ARCH_CHECK=$(eval uname -m)

E_SELINUX=50
E_ARCH=51
E_NOYUM=52
E_NOSUPPORT=53
E_HASDB=54
E_REBOOT=55
E_NOTROOT=85

C_OK=" OK \n"
C_NO=" NO \n"
C_MISS=" UNDETERMINED \n"

clear

# Check if user is root.
if [ "$UID" -ne "0" ] ; then
	echo -en "Installing as \"root\"        " $C_NO
	echo -e "\a\nYou must be \"root\" to install $APP_NAME.\n\nAborting ...\n"
	exit $E_NOTROOT
else
	echo -en "Installing as \"root\"        " $C_OK
fi

# Check if OS is RHEL/CENTOS/FEDORA.
if [ ! -f /etc/redhat-release ] ; then
	echo -en "Operating System supported  " $C_NO
	echo -e "\a\nSorry, only RedHat EL and CentOS are supported by $APP_NAME at this time.\n\nAborting ...\n"
	exit $E_NOSUPPORT
else
	echo -en "Operating System supported  " $C_OK
fi

# Check if selinuxenabled exists
if [ ! -f $SELINUX_CHECK ] ; then
	echo -en "SELinux not installed       " $C_MISS
else
	# Check if SElinux is enabled from exit status. 0 = Enabled; 1 = Disabled;
	eval $SELINUX_CHECK
	OUT=$?
	if [ $OUT -eq "0" ] ; then
		echo -en "SELinux disabled            " $C_NO
        setenforce 0
		echo "SELINUX=disabled" > $SELINUX_CFG
		echo -e "SELinux disabled successfully\n"
	elif [ $OUT -eq "1" ] ; then
		echo -en "SELinux disabled            " $C_OK
	fi
fi

# Check if yum is installed.
if ! [ -f /usr/sbin/yum ] && ! [ -f /usr/bin/yum ] ; then
	echo -en "Yum installed               " $C_NO
	echo -e "\a\nThe installer requires YUM to continue. Please install it and try again.\nAborting ...\n"
	exit $E_NOYUM
else
	echo -en "Yum installed               " $C_OK
fi

# Start install
if [ ! -f /usr/local/lxlabs/ext/php/php ] ; then
	yum -y install php php-mysql wget zip unzip
fi

export PATH=/usr/sbin:/sbin:$PATH

if [ -d ./kloxo/install ] ; then
	cd ./kloxo/install
else
	unzip -oq kloxo-mr-latest.zip kloxo/install/* -d ./
	cd ./kloxo/install
fi

if [ -f /usr/local/lxlabs/ext/php/php ] ; then
	lxphp.exe installer.php --install-type=$APP_TYPE $* | tee kloxo-mr_install.log
else
	php installer.php --install-type=$APP_TYPE $* | tee kloxo-mr_install.log
fi

