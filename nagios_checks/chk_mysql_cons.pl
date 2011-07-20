#!/usr/bin/perl -w

# Copyright (C) 2010 - astera <astera@siliconninjas.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use Getopt::Std;
use DBI();
use lib "/usr/lib/nagios/plugins";
use utils qw(%ERRORS);

use vars qw/ %opt /;
sub debug($);

getopts('u:p:d:H:w:c:h', \%opt);


if (exists $opt{h}) {
  print << "EOF";
Check the number of connections to a MySQL database.
Usage: $0 [options]
-w WARNING threshold (defaults to max_connections/2)
-c CRITICAL threshold (defaults to max_connections)
-H host (default: 127.0.0.1)
-u user (default: nagios)
-p password (default: password)
-d turn on debugging
-h display this help information
EOF
  exit(0);
}

my $max_conns;
my $connections;

my $debug = 0;
if (exists $opt{d}) {
  print "Enabling debug mode\n";
  $debug = 1;
}

my $user = "nagios";
if (exists $opt{u}) {
  $user = $opt{u};
}

my $pass = "password";
if (exists $opt{p}) {
  $pass = $opt{p};
}

my $database = "mysql";
if (exists $opt{d}) {
  $database = $opt{d};
}

my $host = "127.0.0.1";
  if (exists $opt{H}) {
$host = $opt{H};
}

my $dbh = DBI->connect("DBI:mysql:database=mysql;host=$host",
            "$user","$pass",
            {'RaiseError' => 1}) or die "Connection Error: $DBI::errstr\n";

my $max_con_sql = $dbh->prepare("SHOW VARIABLES WHERE Variable_name='max_connections'");
$max_con_sql->execute() or die "SQL Error: $DBI::errstr\n";
while (my $ref = $max_con_sql->fetchrow_hashref()) {
  $max_conns = $ref->{'Value'};
}
debug("\$max_conns=$max_conns\n");
$max_con_sql->finish();

my $warn = $max_conns/2;
if (exists $opt{w}) {
  $warn = $opt{w};
}
debug("\$warn=$warn\n");

my $crit = $max_conns;
if (exists $opt{c}) {
  $crit = $opt{c};
}
debug("\$crit=$crit\n");

my $conns_sql = $dbh->prepare("SHOW GLOBAL STATUS WHERE Variable_name='Threads_connected'");
$conns_sql->execute() or die "SQL Error: $DBI::errstr\n";
while (my $ref_ = $conns_sql->fetchrow_hashref()) {
  $connections = $ref_->{'Value'};
}
debug("\$connections=$connections\n");
$conns_sql->finish();

my $perfdata = "mysql_connections=$connections;$warn;$crit;0;0;";

if ($connections > $crit) {
  print "CRITICAL: $connections connections to MySQL database!|$perfdata\n";
  exit $ERRORS{'CRITICAL'};
} elsif ($connections > $warn) {
  print "WARNING: $connections connections to MySQL database!|$perfdata\n";
  exit $ERRORS{'WARNING'};
} else {
  print "OK: $connections connections to MySQL database|$perfdata\n";
  exit $ERRORS{'OK'};
}

$dbh->disconnect();

sub debug($) {
  if ($debug) {
    print STDERR $_[0];
  }
}
