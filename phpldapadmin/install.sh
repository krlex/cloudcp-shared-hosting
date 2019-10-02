PHPLDAPADMIN_VERSION="4.9.1"

wget http://sourceforge.net/projects/phpldapadmin/files/phpldapadmin-php5/$PHPLDAPADMIN_VERSION/phpldapadmin-$PHPLDAPADMIN_VERSION.tgz/download -O phpldapadmin-$PHPLDAPADMIN_VERSION.tgz
[ $? = "0" ] || error "Error downloading phpldapadmin"

tar xzvf phpldapadmin-$PHPLDAPADMIN_VERSION.tgz

[ ! -d "/usr/local/nginx/html/phpldapadmin" ] || mkdir /usr/local/nginx/html/phpldapadmin

mv phpldapadmin-$PHPLDAPADMIN_VERSION /usr/local/nginx/html/phpldapadmin
mv /usr/local/nginx/html/phpldapadmin/config/config.php.example /usr/local/nginx/html/phpldapadmin/config/config.php

cd ..
