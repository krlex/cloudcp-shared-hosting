;
; BIND data file for example.com
;
$TTL	3600
@	IN	SOA	ns1.example.com. hostmaster.example.com. (
			     1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 3600 )	; Negative Cache TTL
;
@	IN	NS	ns1.example.com.
@	IN	NS	ns2.example.com.

@	IN	A	127.0.0.1
www	IN	A	127.0.0.1

ns1	IN	A	127.0.0.1
ns2	IN	A	127.0.0.1

mail	IN	A	127.0.0.1

@	IN	MX	10	mail.example.com.

@	IN	TXT	"v=spf1" "ip4:127.0.0.1" "-all"
