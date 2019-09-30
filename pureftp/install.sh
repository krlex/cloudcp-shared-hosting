wget ftp://ftp.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.32.tar.gz
[ $? = "0" ] || error "Error downloading PureFTP"

tar xzvf pure-ftpd-1.0.32.tar.gz
cd pure-ftpd-1.0.32
./configure --with-ldap --with-throttling --with-ratios --with-quotas
[ $? = "0" ] || error "Error configuring PureFTP"

make
[ $? = "0" ] || error "Error compiling PureFTP"

make install
[ $? = "0" ] || error "Error installing PureFTP"

cp configuration-file/pure-config.pl /usr/local/sbin
#cp configuration-file/pure-ftpd.conf /usr/local/etc

cd ..

cp pureftpd-ldap.conf /usr/local/etc
cp pure-ftpd.conf /usr/local/etc
sed -i 's/^LDAPBaseDN.*/LDAPBaseDN\t\t'$LDAP_BASE_DN'/' /usr/local/etc/pureftpd-ldap.conf
sed -i 's/^LDAPBindDN.*/LDAPBindDN\t\t'$LDAP_MANAGER_DN'/' /usr/local/etc/pureftpd-ldap.conf
sed -i 's/^LDAPBindPW.*/LDAPBindPW\t\t'$LDAP_MANAGER_PASSWORD'/' /usr/local/etc/pureftpd-ldap.conf
sed -i 's/^LDAPDefaultUID.*/LDAPDefaultUID\t\t'`id -u $HTTP_USER`'/' /usr/local/etc/pureftpd-ldap.conf
sed -i 's/^LDAPDefaultGID.*/LDAPDefaultGID\t\t'`id -u $HTTP_USER`'/' /usr/local/etc/pureftpd-ldap.conf

cp pureftpd-init.$PLATFORM /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd
chmod +x /usr/local/sbin/pure-config.pl
. ./install-init.$PLATFORM
service pureftpd start &

cd ..
