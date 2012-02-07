#!/bin/bash

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

# Exit codes:
# 0 = $STATE_OK
# 1 = $STATE_WARNING
# 2 = $STATE_CRITICAL
# 3 = $STATE_UNKNOWN

HELP='All required interfaces will be checked automagically for speed and link mode; however, if you would like to skip speed checks, please set the -x flag!'

ls_int=0
exit_status=3

our_ethtool=`which ethtool`

if [ $# -gt 1 ]; then
    while getopts 'hx:' OPTIONS; do
        case $OPTIONS in
            x) $ls_int=1;;
            *) echo $HELP; exit 3;;
        esac
    done
fi

for int in `/sbin/ifconfig -a | grep ^eth | grep -v ^eth[0-9]:[0-9] | awk '{print $1}'`; do

    if [ `grep $int /etc/network/interfaces | grep -v ^# | wc -l` -ge 1 ]; then
    duplex=`sudo $our_ethtool $int | grep Duplex | awk '{print $2}'`

        if [ $duplex == 'Full' ]; then
            echo -n 'Interface' $int 'running on Full Duplex. '
            exit_status=0
        elif [ $duplex == 'Half' ]; then
            echo -n 'Interface' $int 'NOT running on Full Duplex! '
            exit_status=2
        else
            echo -n 'Error while running link mode check! '
            exit_status=3
        fi

        if [ $ls_int == 0 ]; then
      speed=`sudo $our_ethtool $int | grep Speed | awk '{print $2}' | awk -F M '{print $1}'`

            if [ $speed == 100 ] || [ $speed == 1000 ]; then
                echo -n 'Speed on interface' $int 'is OK. '
            elif [ $speed == 10 ]; then
        echo -n 'Speed on interface' $int 'is down to 10MBit! '
                exit_status=2
            else
        echo -n 'Speed of interface' $int 'unknown, interface appears to be down! '
        exit_status=2
            fi
        else
            echo -n 'Speed not checked. '
        fi
    fi

done

exit $exit_status
