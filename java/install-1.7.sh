JAVA_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-x64.tar.gz"
JAVA_EXTRACTED_DIR="jdk1.7.0"
JAVA_TAR_NAME="jdk-7-linux-x64.tar.gz"

. ./functions

prompt_install_java

if [ "$JAVA_INSTALL" = "y" ]; then

   wget $JAVA_DOWNLOAD_URL
   [ $? = "0" ] || error "Error downloading java $JAVA_VERSION"

   tar xzvf $JAVA_TAR_NAME
   mv $JAVA_EXTRACTED_DIR /usr/local/jdk
   echo "export JAVA_HOME=/usr/local/jdk" > /etc/profile.d/java.sh
   echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java.sh
   chmod 755 /etc/profile.d/java.sh
   /etc/profile.d/java.sh
fi
