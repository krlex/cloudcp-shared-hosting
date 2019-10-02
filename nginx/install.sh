NGINX_WORKERS=`cat /proc/cpuinfo | grep processor | wc -l`

. ./deps.$PLATFORM

wget http://nginx.org/download/nginx-1.9.9.tar.gz
[ $? = "0" ] || error "Error downloading nginx source"


tar xzvf nginx-1.9.9.tar.gz
cd nginx-1.9.9/
. ../configure.$PLATFORM
[ $? = "0" ] || error "Error configuring nginx source"

make
[ $? = "0" ] || error "Error compiling nginx source"


make install
[ $? = "0" ] || error "Error installing nginx"


cd ..


if [ -z "`id -u $HTTP_USER`" ]; then
   useradd $HTTP_USER
fi

if [ -d "$HTTP_CONF_DIR/vhosts" ]; then
   mkdir "$HTTP_CONF_DIR/vhosts"
fi

cp nginx.conf nginx.conf.import
sed -i 's#include @vhost_path@#include \/usr\/local\/nginx\/conf\/vhosts\*#' nginx.conf.import
sed -i 's/^worker_processes.*/worker_processes '$NGINX_WORKERS';/' nginx.conf.import
sed -i 's/^user.*/user '$HTTP_USER';/' nginx.conf.import
mv nginx.conf.import /usr/local/nginx/conf/nginx.conf
cp fastcgi_php_params /usr/local/nginx/conf
[ $? = "0" ] || error "Error creating nginx configuration"

cp nginx-init.$PLATFORM /etc/init.d/nginx
chmod +x /etc/init.d/nginx
. ./install-init.$PLATFORM
service nginx start

echo "<?php echo phpinfo(); ?>" > /usr/local/nginx/html/index.php

cd ..
