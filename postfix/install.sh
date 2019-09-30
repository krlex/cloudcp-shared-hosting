source deps.$PLATFORM

# Download source
wget ftp://ftp.reverse.net/pub/postfix/official/postfix-2.8.4.tar.gz
[ $? = "0" ] || error "Error creating downloading Postfix source" 

# Install Postfix w/ LDAP support
tar xzvf postfix-2.8.4.tar.gz
cd postfix-2.8.4

# Create postfix users
useradd postfix
[ $? = "0" ] || error "Error creating Postfix user" 

useradd postdrop
[ $? = "0" ] || error "Error creating postdrop user"

useradd vmail
[ $? = "0" ] || error "Error creating virtual mail user" 

POSTFIX_VMAIL_UID=`id -u vmail`
POSTFIX_VMAIL_GID=`id -g vmail`


# Compile the source
make -f Makefile.init makefiles \
CCARGS='-fPIC \
-DUSE_TLS \
-DUSE_SSL \
-DUSE_SASL_AUTH \
-DUSE_CYRUS_SASL \
-DPREFIX=\"/usr\" \
-DHAS_LDAP \
-DLDAP_DEPRECATED=1 \
-DHAS_PCRE \
-I/usr/include/openssl \
-I/usr/include/sasl \
-I/usr/include' \
AUXLIBS='-L/usr/lib64 \
-L/usr/lib64/openssl \
-L/usr/local/bdb/lib \
-L/usr/local/ssl/lib -lssl -lcrypto \
-L/usr/lib64/sasl2 -lsasl2 -lpcre -lldap -llber \
-Wl,-rpath,/usr/lib64/openssl -pie -Wl,-z,relro' \
OPT='-O' \
DEBUG='-g'


make
[ $? = "0" ] || error "Error compiling Postix" 

sh postfix-install -non-interactive
[ $? = "0" ] || error "Error installing Postix" 

cd ../

# Create chrooted log directory
if [ ! -d "/var/spool/poxtfix/dev/log" ]; then
   mkdir -p /var/spool/postfix/dev/log
fi

# Postfix configs
mkdir -p $MAIL_BASE
mkdir /etc/postfix/ssl

if [ $? != "0" ]; then
echo "Error setting up Postfix directory structure"
exit 1
fi

# Configure conf templates with the environment defined LDAP server DN
cd conf
for i in `ls | grep virtual`
  do
     cp $i $i.import
     sed -i 's/^search_base.*$/search_base = "'$LDAP_BASE_DN'"/' $i.import
     cp $i.import /etc/postfix/$i
     postmap /etc/postfix/$i
  done

[ $? = "0" ] || error "Error hashing Postfix LDAP lookup tables"

cd ../

# Configure main.cf
cp conf/main.cf /etc/postfix/main.cf
sed -i 's:^virtual_mailbox_base.*$:virtual_mailbox_base = '$MAIL_BASE':' /etc/postfix/main.cf
sed -i 's/^virtual_uid_maps.*$/virtual_uid_maps = '$POSTFIX_VMAIL_UID'/' /etc/postfix/main.cf
sed -i 's/^virtual_gid_maps.*$/virtual_gid_maps = '$POSTFIX_VMAIL_GID'/' /etc/postfix/main.cf
sed -i 's/@hostname@/'$MAIL_HOSTNAME'/' /etc/postfix/main.cf


# Postfix chroot configs
if [ ! -d "/var/spool/postfix/etc" ]; then
   mkdir /var/spool/postfix/etc
fi

if [ ! -d "/var/spool/postfix/dev/log" ]; then
   mkdir -p /var/spool/postfix/dev/log
fi

if [ ! -d "/var/spool/postfix/var/run/saslauthd" ]; then
   mkdir -p /var/spool/postfix/var/run/saslauthd
fi

# Copy required "external" files into the chroot
cp /etc/services /var/spool/postfix/etc/services
cp /etc/hosts /var/spool/postfix/etc/hosts


# Install Postfix init script
cp postfix-init.$PLATFORM /etc/init.d/postfix
chmod +x /etc/init.d/postfix
. ./install-init.$PLATFORM
service postfix start
[ $? = "0" ] || error "Error setting up Postfix init script"


# Integrate SASL
#usermod -a -G sasl postfix
#[ $? = "0" ] || error "Error adding Postfix to sasl group"

mkdir /etc/postfix/sasl
cp sasl/smtpd.conf /etc/postfix/sasl/smtpd.conf

if [ $ARCH = "64" ]; then
   ln -s /etc/postfix/sasl/smtpd.conf /usr/lib64/sasl2/smtpd.conf
else
   ln -s /etc/postfix/sasl/smtpd.conf /usr/lib/sasl2/smtpd.conf
fi

[ $? = "0" ] || error "Error copying Postfix SASL SMTP configuration file"

cp /etc/sasldb2 /var/spool/postfix/etc
chown root.postfix /var/spool/postfix/etc/sasldb2
chown root.postfix /var/spool/postfix/etc/sasldb2
chown 660 /var/spool/postfix/etc/sasldb2

service saslauthd start


# SSL
#openssl genrsa -des3 -out ssl/$MAIL_HOSTNAME.key 2048
#openssl rsa -in ssl/$MAIL_HOSTNAME.key -out ssl/$MAIL_HOSTNAME.insecure.key
#openssl req -new -key ssl/$MAIL_HOSTNAME.key -out ssl/$MAIL_HOSTNAME.csr
#openssl x509 -req -days 365 -in ssl/$MAIL_HOSTNAME.csr -signkey ssl/$MAIL_HOSTNAME.key -out ssl/ssl/$MAIL_HOSTNAME.crt


cd ../
