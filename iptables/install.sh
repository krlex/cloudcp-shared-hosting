chmod 770 iptables.$PLATFORM.sh
cp iptables.$PLATFORM.sh /etc/iptables.sh
cp iptables-init.$PLATFORM /etc/init.d/iptables
. ./install-init.$PLATFORM
chmod +x /etc/init.d/iptables
service iptables start
cd ..
