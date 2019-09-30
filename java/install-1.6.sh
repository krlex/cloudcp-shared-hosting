wget http://download.oracle.com/otn-pub/java/jdk/6u26-b03/jdk-6u26-linux-x64.bin -O jdk.bin
[ $? = "0" ] || error "Error downloading java $JAVA_VERSION"

chmod 770 jdk.bin
./jdk.bin <<EOF
y
EOF

mv jdk1.6.0_26/ /usr/local/jdk
echo "export JAVA_HOME=/usr/local/jdk" > /etc/profile.d/java.sh
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java.sh
chmod 755 /etc/profile.d/java.sh
source /etc/profile.d/java.sh
