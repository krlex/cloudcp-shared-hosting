if [ "$PLATFORM" = "redhat" ]; then

    yum -y install sysklogd.x86_64
    service sysklogd stop
    cp syslogd.redhat /etc/sysconfig/syslog
    chown root.root /etc/sysconfig/syslog
    chmod 644 /etc/sysconfig/syslog
    service syslog restart

elif [ "$PLATFORM" = "debian" ]; then

    apt-get --assume-yes install sysklogd
    service sysklogd stop
    cp syslogd.debian /etc/init.d/syslog
    update-rc.d -f syslog defaults
    service sysklogd start
fi

cd ..
