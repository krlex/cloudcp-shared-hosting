#!/usr/bin/perl

# @see http://thunder.jbdesign.net/docs/postfix-zenoss.html

use DB_File; use File::Tail ; $debug = 0;

$mail_log = '/var/log/maillog' ; $stats_file = '/tmp/stats.db' ;

$db = tie(%stats, "DB_File", "$stats_file", O_CREAT|O_RDWR, 0666, $DB_HASH)
    || die ("Cannot open $stats_file");

#my $logref=tie(*LOG,"File::Tail",(name=>$mail_log,tail=>-1,debug=>$debug)); my $logref=tie(*LOG,"File::Tail",(name=>$mail_log,debug=>$debug));

while () {

    if (/status=sent/) {
		next unless (/ postfix\//) ;
		# count sent messages
		if (/relay=([^,]+)/o) {
			$relay = $1 ;
			#print "$relay..." ;
		} ;
		if ($relay !~ /\[/o ) {
			$stats{"SENT:$relay"} += 1;
			#print "$relay\n" ;
		} else {
			$stats{"SENT:smtp"} +=1 ;
			#print "smtp\n" ;
		} ;
		$db->sync;
    } elsif (/status=bounced/) {
        $stats{"BOUNCED:smtp"} += 1; $db->sync ;
    } elsif (/NOQUEUE: reject/) {
        $stats{"REJECTED:smtp"} += 1; $db->sync ;
    } elsif (/smtpd.*client=/) {
        $stats{"RECEIVED:smtp"} += 1; $db->sync ;
    } elsif (/pickup.*(sender|uid)=/) {
        $stats{"RECEIVED:local"} += 1; $db->sync ;
    } ;

} ;

untie $logref ; untie %stats;

