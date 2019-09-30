mkdir -p /opt/cloudcp/mail/example.com/user1
cd /opt/cloudcp/mail/example.com/user1

maildirmake Maildir
maildirmake -f Drafts Maildir
maildirmake -f Sent  Maildir
maildirmake -f Trash Maildir
maildirmake -q 2147483648S Maildir

chown -R vmail.vmail /opt/cloudcp/mail
