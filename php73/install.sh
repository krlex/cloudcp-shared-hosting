PHP_VERSION=7.3

. ./deps.$PLATFORM

wget http://us2.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror
[ $? = "0" ] || error "Error downloading PHP source"

mv mirror php-$PHP_VERSION.tar.gz
tar xzvf php-$PHP_VERSION.tar.gz
cd php-$PHP_VERSION

#./configure --with-openssl --with-pear --with-ldap=/usr --with-curl -with-gettext --with-mcrypt --with-xsl --#enable-mbstring --enable-sockets --enable-soap --enable-fpm --enable-cgi --with-pdo-mysql --with-mysql --with-#libdir=lib64

./configure \
--enable-sockets \
--enable-calendar \
--enable-mbstring \
--enable-soap \
--enable-fpm \
--enable-cgi \
--enable-cli \
--enable-shmop \
--enable-mbregex \
--enable-inline-optimization \
--with-openssl \
--with-pear \
--with-ldap=/usr \
--with-curl \
--with-curlwrappers \
--with-gettext \
--with-mcrypt \
--with-xsl \
--with-pdo-mysql=/usr/local/mysql \
--with-mysql=/usr \
--with-gd \
--with-zlib \
--with-jpeg-dir=/usr/lib \
--with-png-dir=/usr/lib \
--with-xpm-dir=/usr/lib \
--with-imap-ssl \
--with-pcre-regex \
--with-mhash \
--with-libdir=lib64
[ $? = "0" ] || error "Error configuring PHP source"

make
[ $? = "0" ] || error "Error compiling PHP"

make install
[ $? = "0" ] || error "Error installing PHP"

useradd php-fpm
[ $? = "0" ] || error "Error creating PHP FastCGI process user"

passwd -l php-fpm
[ $? = "0" ] || error "Error locking PHP FastCGI user account"

cd ..

cp php-fpm.conf /usr/local/etc/php-fpm.conf
cp php-$PHP_VERSION/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
. ./install-init.$PLATFORM
service php-fpm start

# cleanup
unset LIBS


cd ../
