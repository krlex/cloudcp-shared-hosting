# Flush iptables
/sbin/iptables --flush

## Local Services ##
/sbin/iptables -A INPUT -p icmp -j ACCEPT                           # Ping
/sbin/iptables -A INPUT -p tcp --dport 22 -j ACCEPT                 # SSH
/sbin/iptables -A INPUT -p tcp --dport 21 -j ACCEPT                 # ProFTPD
/sbin/iptables -A INPUT -p tcp --dport 25 -j ACCEPT                 # Postfix (SMTP)
/sbin/iptables -A INPUT -p tcp --dport 53 -j ACCEPT                 # Bind (TCP)
/sbin/iptables -A INPUT -p udp --dport 53 -j ACCEPT                 # Bind (UDP)
/sbin/iptables -A INPUT -p tcp --dport 80 -j ACCEPT                 # Nginx
/sbin/iptables -A INPUT -p tcp --dport 110 -j ACCEPT                # Courier (POP)
/sbin/iptables -A INPUT -p tcp --dport 143 -j ACCEPT                # Courier (IMAP)
/sbin/iptables -A INPUT -p tcp --dport 465 -j ACCEPT                # Postfix (SMTPS)
/sbin/iptables -A INPUT -p tcp --dport 587 -j ACCEPT                # Postfix (Submission)
/sbin/iptables -A INPUT -p tcp --dport 993 -j ACCEPT                # Courier (IMAPS)
/sbin/iptables -A INPUT -p tcp --dport 995 -j ACCEPT                # Courier (POPS)
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 111 -j ACCEPT   # Speed up mail via courier. Identified via logging
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 3306 -j ACCEPT  # MySQL
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 389 -j ACCEPT   # OpenLDAP (LDAP)
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 636 -j ACCEPT   # OpenLDAP (LDAPS)
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 953 -j ACCEPT   # RNDC (Bind Administration)
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 9000 -j ACCEPT  # PHP FastCGI
/sbin/iptables -A INPUT -s 127.0.0.1 -p tcp --dport 8080 -j ACCEPT  # JBoss

# Block fragments and Xmas tree as well as SYN,FIN and SYN,RST
/sbin/iptables -A INPUT -p ip -f -j DROP
/sbin/iptables -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
/sbin/iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
/sbin/iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# Block new connections without SYN
/sbin/iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# Stateful Packet Inspection Firewall - Allow incoming responses to outbound established connections
/sbin/iptables -A INPUT -p tcp -m tcp --tcp-flags ACK ACK -j ACCEPT
/sbin/iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
/sbin/iptables -A INPUT -m state --state RELATED -j ACCEPT

# Log the packet and reject it
/sbin/iptables -A INPUT -m limit --limit 15/minute -j LOG --log-level 7
/sbin/iptables -A INPUT -j REJECT
