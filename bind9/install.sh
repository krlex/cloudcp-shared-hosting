. ./functions
get_chroot_path


if [ ! -d "$DNS_CHROOT/named/etc" ]; then
   mkdir -p $DNS_CHROOT/named/etc
fi

# Create named user account
useradd -s /bin/false named
[ $? = "0" ] || error "Error creating named user account"

passwd -l named

# Create chroot directory structure
if [ ! -d "$DNS_CHROOT/named/dev" ]; then
    mkdir -p $DNS_CHROOT/named/dev
fi

if [ ! -d "$DNS_CHROOT/named/etc/db/slave" ]; then
    mkdir -p $DNS_CHROOT/named/etc/db/slave
fi

if [ ! -d "$DNS_CHROOT/named/var/run" ]; then
    mkdir -p $DNS_CHROOT/named/var/run
fi


if [ ! -d "$DNS_CHROOT/named/var/run" ]; then
    mkdir -p $DNS_CHROOT/named/var/cache/named
fi

# Create null and random devices.
if [ ! -d "$DNS_CHROOT/named/dev/null" ]; then
   mknod $DNS_CHROOT/named/dev/null c 1 3
fi

if [ ! -d "$DNS_CHROOT/named/dev/random" ]; then
   mknod $DNS_CHROOT/named/dev/random c 1 8
fi

chmod 666 $DNS_CHROOT/named/dev/{null,random}

# Copy required "outside" files into the jail
cp /etc/localtime $DNS_CHROOT/named/etc/

# Download and install
wget ftp://ftp.isc.org/isc/bind/9.9.9-P8/bind-9.9.9-P8.tar.gz
[ $? = "0" ] || error "Error downloading BIND DNS source"


tar xzvf bind-9.9.9-P8.tar.gz
cd bind-9.9.9-P8
./configure --with-openssl=/usr/local/ssl
[ $? = "0" ] || error "Error configuring BIND DNS source"


make
[ $? = "0" ] || error "Error compiling BIND DNS source"


make install
[ $? = "0" ] || error "Error installing BIND DNS"

cd ../

# Configuration files
if [ ! -f "$DNS_CHROOT/named/etc/rndc.key" ]; then
    rndc-confgen -a -c $DNS_CHROOT/named/etc/rndc.key -r /dev/urandom
fi

ln -s $DNS_CHROOT/named/etc/rndc.key /etc/rndc.key

cp conf/* $DNS_CHROOT/named/etc
cp zones/* $DNS_CHROOT/named/etc/db

if [ ! -d "$DNS_CHROOT/named/var/cache/named" ]; then
   mkdir -p $DNS_CHROOT/named/var/cache/named
fi


touch $DNS_CHROOT/named/var/cache/named/managed-keys.bind
[ $? = "0" ] || error "Error creating managed-keys.bind"


# BIND / OpenSSL 1.0.0d Bug Fix
# @see https://bugs.mageia.org/show_bug.cgi?id=871
if [ ! -d "$DNS_CHROOT/named/usr/local/ssl/lib/engines" ]; then
    mkdir -p $DNS_CHROOT/named/usr/local/ssl/lib/engines
    cp /usr/local/ssl/lib/engines/libgost.so $DNS_CHROOT/named/usr/local/ssl/lib/engines
fi


# Set permissions
chown root $DNS_CHROOT
chown -R named.named $DNS_CHROOT/named
chmod -R 774 $DNS_CHROOT/named/var/run


# Install startup script
cp named-init.$PLATFORM /etc/init.d/named
sed -i 's:@DNS_CHROOT@:'$DNS_CHROOT':g' /etc/init.d/named
chmod +x /etc/init.d/named
. ./install-init.$PLATFORM
service named start


# Set server to use itself for DNS
echo "search $LDAP_DOMAIN" > /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf


cd ../
