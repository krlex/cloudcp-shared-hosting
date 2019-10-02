OPENLDAP_VERSION=2.4.30

. ./deps.$PLATFORM
. ./functions

if [ -z "$LDAP_ORG" ]; then

   echo "Enter your company / organization name (My Company, inc)."
   read LDAP_ORG
   if [ -z "$LDAP_ORG" ]; then
      LDAP_ORG="My Company, inc"
   fi
fi

if [ -z "$LDAP_DOMAIN" ]; then

   echo "Enter the CloudCP domain (cloudcp.local)."
   read LDAP_DOMAIN
   if [ -z $LDAP_DOMAIN ]; then
      LDAP_DOMAIN="cloudcp.local"
   fi
fi

if [ -z "$LDAP_MANAGER" ]; then
   echo "Enter the name of the LDAP manager account (Manager)."
   read LDAP_MANAGER
   if [ -z $LDAP_MANAGER ]; then
      LDAP_MANAGER="Manager"
   fi
fi

if [ -z "$LDAP_MANAGER_PASSWORD" ]; then
   echo "Setting the LDAP Manager password."
   get_ldap_password
fi

# Split the domain on the .
arr=$(echo $LDAP_DOMAIN | tr "." "\n")
LDAP_BASE_DN=""
LDAP_DC=""

# Concatenate the domain pieces into an LDAP distinguished name
for x in $arr
do
    LDAP_BASE_DN="$LDAP_BASE_DN,dc=$x"
    if [ -z $LDAP_DC ]; then
       LDAP_DC=$x
    fi
done
LDAP_BASE_DN=${LDAP_BASE_DN:1}

# Create the full DN
LDAP_MANAGER_DN="cn=$LDAP_MANAGER,$LDAP_BASE_DN"


# Create OpenLDAP user account
#useradd openldap
#[ $? = "0" ] || error "Error creating OpenLDAP user account"

wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-stable/openldap-stable-20120311.tgz
[ $? = "0" ] || error "Error downloading OpenLDAP"

tar xzvf openldap-stable-20120311.tgz
cd openldap-$OPENLDAP_VERSION

export CPPFLAGS="${CPPFLAGS} -I/usr/local/bdb/include"
export LDFLAGS="-L/usr/lib64 -L/usr/local/bdb/lib -R/usr/local/bdb/lib"
export LD_LIBRARY_PATH="/usr/local/bdb/lib"

./configure --with-dbd --enable-dbd --enable-hdb=yes --enable-monitor=yes --enable-relay=yes --enable-sql=no --enable-static=yes --enable-shared=yes --with-threads --with-tls=no
[ $? = "0" ] || error "Error configuring OpenLDAP"

make depend
[ $? = "0" ] || error "Error building OpenLDAP dependencies"

make
[ $? = "0" ] || error "Error compiling OpenLDAP"

make install
[ $? = "0" ] || error "Error installing OpenLDAP"

cd ..

# Copy configuration templates
cp cloudcp.schema /usr/local/etc/openldap/schema && \
cp slapd.conf /usr/local/etc/openldap && \
cp /usr/local/var/openldap-data/DB_CONFIG.example /usr/local/var/openldap-data/DB_CONFIG && \
chown root.openldap /usr/local/etc/openldap/slapd.conf
cp slapd-init.$PLATFORM /etc/init.d/slapd
. ./install-init.$PLATFORM
chmod +x /etc/init.d/slapd
[ $? = "0" ] || error "Error copying OpenLDAP configuration files"


# Configure slapd.conf
sed -i 's/^suffix.*$/suffix\t\t"'$LDAP_BASE_DN'"/' $LDAP_CONF
sed -i 's/^rootdn.*$/rootdn\t\t"'$LDAP_MANAGER_DN'"/' $LDAP_CONF
sed -i 's/^rootpw.*$/rootpw\t\t'$LDAP_MANAGER_PASSWORD'/' $LDAP_CONF
[ $? = "0" ] || error "Error configuring $LDAP_CONF"


service slapd start
sleep 2


# Add ldif files - basedn and password are defined in /config.source
cd ldif
for i in `ls`
  do
     cp $i $i.import
     sed -i 's/@basedn@/'"$LDAP_BASE_DN"'/' $i.import
     sed -i 's/@dc@/'"$LDAP_DC"'/' $i.import
     sed -i 's/@org@/'"$LDAP_ORG"'/' $i.import
     ldapadd -f $i.import -D "$LDAP_MANAGER_DN" -x -w $LDAP_MANAGER_PASSWORD
  done

cd ..


[ $? = "0" ] || error "Error importing OpenLDAP LDIF files"


# Cleanup
unset LDFLAGS
unset LD_LIBRARY_PATH


if [ "$ARCH" = "64" ]; then

   #ln -s /usr/local/include/ldap.h /usr/include
   #ln -fs /usr/lib/libldap* /usr/lib64
   #ln -fs /usr/lib/libldap* /usr/local/lib64
   #ln -fs /usr/local/lib/libldap* /usr/lib64
   #ln -fs /usr/lib/liblber* /usr/lib64
   #ln -fs /usr/lib/liblber* /usr/local/lib64
   #ln -fs /usr/local/lib/liblber* /usr/lib64

   ln -fs /usr/lib/liblber-2.4.so.2 /usr/local/lib/liblber-2.4.so.2
   ln -fs /usr/lib/libldap_r-2.4.so.2 /usr/local/lib/libldap_r-2.4.so.2
   ln -fs /usr/lib/libldap_r-2.4.so.2 /usr/local/lib/libldap.so
   rm /usr/local/lib/liblber.so
   ln -fs /usr/local/lib/liblber-2.4.so.2 /usr/local/lib/liblber.so

fi


cd ../
