#!/usr/bin/perl

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

use Env;

my $now = localtime;
my @user = getpwuid($<);
my $mailer = "/usr/sbin/sendmail.act";

open (GOTCHA, ">> /var/log/sendmail_wrap.log") || die "Failed to open logfile: $!";

if ($SCRIPT_FILENAME) {
  print GOTCHA "$now - sent from $SCRIPT_FILENAME (by $REMOTE_ADDR)\n";
} else {
  print GOTCHA "$now - sent from dir $PWD (by user: @user[0,2,7,8])\n";
}

close (GOTCHA);

foreach (@ARGV) {
  $arg = "$arg" . " $_";
}

open (MAILER, " | $mailer $arg") || die "No mail program here by that name, sorry! - $!\n";

while (<STDIN>) {
  print MAILER;
}

close (MAILER);
