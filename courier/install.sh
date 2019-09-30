. ./deps.$PLATFORM

# Courier authlib
wget https://sourceforge.net/projects/courier/files/authlib/0.63.0/courier-authlib-0.63.0.tar.bz2/download -O courier-authlib-0.63.0.tar.bz2
[ $? = "0" ] || error "Error downloading Courier authlib"

bzip2 -d courier-authlib-0.63.0.tar.bz2
tar xvf courier-authlib-0.63.0.tar
cd courier-authlib-0.63.0

./configure
[ $? = "0" ] || error "Error configuring Courier authlib"

make
[ $? = "0" ] || error "Error compiling Courier authlib"

make install
[ $? = "0" ] || error "Error installing Courier authlib"

cd ..

# Courier authlib configs
cp authdaemonrc /usr/local/etc/authlib
cp authldaprc /usr/local/etc/authlib

sed -i 's/^LDAP_BASEDN.*$/LDAP_BASEDN\t\t'$LDAP_BASE_DN'/' /usr/local/etc/authlib/authldaprc
sed -i 's/^LDAP_BINDDN.*$/LDAP_BINDDN\t\t'$LDAP_MANAGER_DN'/' /usr/local/etc/authlib/authldaprc
sed -i 's/^LDAP_BINDPW.*$/LDAP_BINDPW\t\t'$LDAP_MANAGER_PASSWORD'/' /usr/local/etc/authlib/authldaprc

# Courier authlib init scripts
cp courier-authlib-init.$PLATFORM /etc/init.d/courier-authlib
chmod 775 /etc/init.d/courier-authlib
. ./install-authlib-init.$PLATFORM
service courier-authlib start
[ $? = "0" ] || error "Error creating Courier authlib init scripts"


# maildrop
wget https://sourceforge.net/projects/courier/files/maildrop/2.5.4/maildrop-2.5.4.tar.bz2/download -O maildrop-2.5.4.tar.bz2
[ $? = "0" ] || error "Error downloading Courier maildrop"

bzip2 -d maildrop-2.5.4.tar.bz2
tar xvf maildrop-2.5.4.tar
cd maildrop-2.5.4

./configure
[ $? = "0" ] || error "Error configuring Courier maildrop"

make
[ $? = "0" ] || error "Error compiling Courier maildrop"

make install
[ $? = "0" ] || error "Error installing Courier maildrop"

chmod +s /usr/local/bin/maildrop
cd ..


# imap, pop3
wget https://sourceforge.net/projects/courier/files/imap/4.9.3/courier-imap-4.9.3.tar.bz2/download -O courier-imap-4.9.3.tar.bz2
[ $? = "0" ] || error "Error downloading Courier IMAP/POP3"

bzip2 -d courier-imap-4.9.3.tar.bz2
tar xvf courier-imap-4.9.3.tar
cd courier-imap-4.9.3

./configure --disable-root-check
[ $? = "0" ] || error "Error configuring Courier IMAP/POP"

make
[ $? = "0" ] || error "Error compiling Courier IMAP/POP"

make install
[ $? = "0" ] || error "Error installing Courier IMAP/POP"


make install-configure
[ $? = "0" ] || error "Error during post-install setup of Courier IMAP/POP"


cd ..

# init scripts
cp imapd-init.$PLATFORM /etc/init.d/imapd
chmod 775 /etc/init.d/imapd
. ./install-imapd-init.$PLATFORM
service imapd start
[ $? = "0" ] || error "Error creating Courier IMAPD init scripts"


cp pop3d-init.$PLATFORM /etc/init.d/pop3d
chmod 775 /etc/init.d/pop3d
. ./install-pop3d-init.$PLATFORM
service pop3d start
[ $? = "0" ] || error "Error creating Courier POP3D init scripts"


# Setup CloudCP maildir root
if [ ! -d "$MAIL_BASE" ]; then
   mkdir -p $MAIL_BASE
   chown -R root.vmail $MAIL_BASE
   chmod -R 775 $MAIL_BASE
fi


# Test authentication
authtest user1@example.com test
[ $? = "0" ] || error "Error authenticating example account"


cd ..
