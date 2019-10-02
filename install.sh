#!/bin/bash


START=$(date +%s)


# Make sure we are root
if [ "`id -u`" != "0" ];then
	echo "You must be root to install this software"
	exit 1
fi

export PATH=$PATH:/sbin:/usr/sbin:/bin

. ./functions
. ./config.cloudcp


# 32 or 64 bit environment?
if [ "`uname -m`" = "x86_64" ]; then
  ARCH="64"
 # export CFLAGS="-m64 -O"
else
  ARCH="32"
fi


# Source the proper distro
if [ -f /etc/redhat-release ]; then

    export PLATFORM="redhat"
    . ./redhat
elif [ -f /etc/debian_version ]; then

    export PLATFORM="debian"
    . ./debian
else

    echo "Your Operating System is not (yet) supported by this installer."
    exit 1
fi


# Install OpenSSL
cd openssl
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building OpenSSL"


# Berkeley DB - OpenLDAP Backend
cd berkeley-db
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building Berkeley DB"


# OpenLDAP
cd openldap
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building OpenLDAP"


# MySQL
cd mysql
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building MySQL"


# PHP
cd php73
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building PHP"


# Nginx
cd nginx
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building Nginx"


# phpLDAPadmin
cd phpldapadmin
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building phpLDAPadmin"


# PureFTP
cd pureftp
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building PureFTP"


# Install SASL
cd sasl
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error installing SASL"


# Install syslogd
cd syslogd
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error installing syslogd"


# BIND DNS
cd bind9
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building BIND DNS"


# Postfix MTA
cd postfix
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building Postfix"


# Courier authlib, maildrop, imapd, and pop3d
cd courier
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error building Courier"


# IPtables firewall
cd iptables
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error setting up firewall"


# Java
cd java
chmod 770 install.sh
. ./install.sh
[ $? = "0" ] || error "Error setting up Java"


END=$(date +%s)
BUILD_TIME=$((($END - $START) / 60))


# Complete
echo
echo
echo "*************************"
echo "* Installation Complete *"
echo "*************************"
echo
echo "Build time: $BUILD_TIME minutes"
echo
echo "Enjoy your new hosting platform!"
echo
echo


exit 0
