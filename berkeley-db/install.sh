DB_VERSION=5.3.28

wget http://anduin.linuxfromscratch.org/BLFS/bdb/db-$DB_VERSION.tar.gz
[ $? = "0" ] || error "Error downloading Berkeley DB"

tar xzvf db-$DB_VERSION.tar.gz
cd db-$DB_VERSION/build_unix
../dist/configure --prefix=/usr/local/bdb
[ $? = "0" ] || error "Error configuring Berkeley DB"

make
[ $? = "0" ] || error "Error compiling Berkeley DB"

make install
[ $? = "0" ] || error "Error installing Berkeley DB"

echo "/usr/local/bdb/lib" > /etc/ld.so.conf.d/bdb.conf
ldconfig

# Postfix expects db.h at /usr/include
ln -s /usr/local/bdb/include/db.h /usr/include/db.h

cd ../../../
