#!/bin/bash

# Copyright (C) 2010 - astera <astera@siliconninjas.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Exit codes:
# 0 = $STATE_OK
# 1 = $STATE_WARNING
# 2 = $STATE_CRITICAL
# 3 = $STATE_UNKNOWN

HELP='The active connections check has to be invoked with the IP and service port to be checked in the format XXX.XXX.XXX.XXX:XXX!'

IPserv=$1

exit_status=3

#if [ $# == 1 ]; then
#    while getopts 'hs:' OPTIONS; do
#        case $OPTIONS in
#            h) echo $HELP; exit 3;;
#            *) IPserv=$1;;
#        esac
#    done
#else
#       echo $HELP; exit 3;
#fi

count=0
our_ipvsadm='sudo /sbin/ipvsadm'

for i in `$our_ipvsadm -L -t $IPserv -n | grep -v 'LocalAddress:Port' | grep -v 'RemoteAddress:Port' | grep -v ^TCP | awk '{print $5}'`; do
    count=$(($count+$i)) 
    exit_status=0
done

echo 'Active connections on ' $IPserv ':' $count '|acons='$count';10000;10000;0;'

exit $exit_status
