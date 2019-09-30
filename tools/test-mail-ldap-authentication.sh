testsaslauthd -s smtp -f /var/spool/postfix/var/run/saslauthd/mux -u user1@example.com -p test
authtest user1@example.com test

## For AUTH PLAIN or AUTH LOGIN from telnet
printf '\0%s\0%s' 'user1@example.com' 'test' | openssl base64
