OPENSSL_VERSION="1.0.2t"

wget http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
[ $? != "0" ] && error "Error downloading OpenSSL"

tar xzvf openssl-$OPENSSL_VERSION.tar.gz
cd openssl-$OPENSSL_VERSION
./config shared

[ $? != "0" ] && error "Error configuring OpenSSL"

make
[ $? != "0" ] && error "Error compiling OpenSSL"

make install
[ $? != "0" ] && error "Error installing OpenSSL"

echo "/usr/local/ssl/lib" > /etc/ld.so.conf.d/ssl.conf
ldconfig

export CPPFLAGS="-I/usr/local/ssl -I/usr/local/ssl/include -I/usr/local/ssl/include/openssl"
ln -s /usr/local/ssl/include/openssl /usr/include

cd ../../
