maildirmake Maildir
maildirmake -f Drafts Maildir
maildirmake -f Sent  Maildir
maildirmake -f Trash Maildir

echo "Setup mailquota of 2 GB"
echo "maildirmake -q 2147483648S Maildir"

echo "Setup mailqouta of 10GB"
echo "maildirmake -q 10737418240S Maildir"
