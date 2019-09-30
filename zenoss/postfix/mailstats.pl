#!/usr/bin/perl

# @see http://thunder.jbdesign.net/docs/postfix-zenoss.html

use DB_File;

$|=1;

$stats_file = '/tmp/stats.db' ;

tie(%foo, "DB_File", "$stats_file", O_RDONLY, 0666, $DB_HASH) || die ("Cannot open $stats_file");

if ($ARGV[0]? =~ /sent/) {

    foreach (sort keys %foo) {
        print $foo{$_} if $_ =~ /SENT/;

    }

} elsif ($ARGV[0]? =~ /received/) {

    foreach (sort keys %foo) {
        print $foo{$_} if $_ =~ /RECEIVED/;

    }

} elsif ($ARGV[0]? =~ /bounced/) {

    foreach (sort keys %foo) {
        print $foo{$_} if $_ =~ /BOUNCED/;

    }

} elsif ($ARGV[0]? =~ /rejected/) {

    foreach (sort keys %foo) {
        print $foo{$_} if $_ =~ /REJECTED/;

    }

} elsif ($ARGV[0]? =~ /queue/) {

    @mailq = split(/n/,`postqueue -p`); @line = split(' ',$mailq[$#mailq]?); print $line[4]?; print $mailq;

}

untie %foo;
