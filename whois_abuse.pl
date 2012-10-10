#!/usr/bin/perl 
use strict;

my $scriptname = $0;
@ARGV || die("Usage: $scriptname <one or more IPs>\n");

while (@ARGV) {
	&whois(shift);
}

sub whois
{	my($arg) = @_;
	my($line);
	my(%email) = ();
	
	if (open(WHOIS, "whois $arg |")) {
		while (defined($line = <WHOIS>)) {
			chop $line;
			$line =~ /([\w-.]+\@[\w-.]+)/ && ($email{$1} = 1);
		}
		close WHOIS;
		print "Email complaints about ", $arg, " to: ", join(" | ", sort keys %email), "\n";
	} else {
		warn "Error: $!\n";
	}
}
