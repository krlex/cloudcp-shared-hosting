# Install dependencies
. ./deps.$PLATFORM
. ./functions

# Set up MySQL user/group
groupadd mysql
[ $? = "0" ] || error "Error creating mysql group"

useradd -g mysql mysql
[ $? = "0" ] || error "Error creating mysql user"

# Download and install MySQL
wget http://mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.15.tar.gz/from/http://mysql.he.net/ -O mysql-5.5.15.tar.gz
[ $? = "0" ] || error "Error downloading mysql user"

tar zxvf mysql-5.5.15.tar.gz
cd mysql-5.5.15

cmake . -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DMYSQL_DATADIR=/usr/local/mysql/data \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DCURSES_LIBRARY=/usr/lib64/libncurses.a \
-DCURSES_INCLUDE_PATH=/usr/lib64 -DHAVE_LIBAIO_H=/usr/lib64 \
-DINSTALL_LAYOUT=STANDALONE -DENABLED_PROFILING=ON \
-DMYSQL_MAINTAINER_MODE=OFF -DWITH_DEBUG=OFF
[ $? = "0" ] || error "Error configuring mysql source"

make
[ $? = "0" ] || error "Error compiling mysql source"

make install
[ $? = "0" ] || error "Error installing mysql"

# Initialize the database
MYSQL_INSTALL_DIR=$PWD
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin
cd /usr/local/mysql
./scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql
[ $? = "0" ] || error "Error initializing mysql source"

chown -R mysql.mysql /usr/local/mysql/data
[ $? = "0" ] || error "Error setting mysql data permissions"

# Configure startup script
cp support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql

cd $MYSQL_INSTALL_DIR/../
. ./install-init.$PLATFORM
[ $? = "0" ] || error "Error installing mysql service"

# TEMP HACK to work around libmysqlclient.so dep install
[ -f "/etc/mysql/my.cnf" ] && mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak

echo "/usr/local/mysql/lib/mysql" > /etc/ld.so.conf.d/mysql.conf
ldconfig

ln -s /usr/local/mysql/lib/* /usr/lib64
ln -s /usr/local/mysql/include/mysql.h /usr/include/mysql.h
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql

service mysql start

get_mysql_password

echo "\n" | /usr/local/mysql/bin/mysqladmin -u root password '$MYSQL_ROOT_PASSWORD'
[ $? = "0" ] || error "Error setting mysql root password"

cd ../
