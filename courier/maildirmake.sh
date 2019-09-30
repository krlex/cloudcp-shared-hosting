# create a maildir as user
maildirmake Maildir

# setup mailquota of 2 GB
maildirmake -q 2147483648S Maildir

# create some folders
maildirmake -f Drafts Maildir
maildirmake -f Sent  Maildir
maildirmake -f Trash Maildir


# setup mailqouta of 10GB
maildirmake -q 10737418240S Maildir


# setup mailquota of 2 GB
maildirmake -q 2147483648S Maildir
