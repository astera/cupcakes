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

HELP='Please specify CRITICAL and WARNING levels (applied to all mounted disks equally) in the following format: ./check_io_stats -w <tps>,<kb/s read>,<kb/s written> -c <tps>,<kb/s read>,<kb/s written>'

exit_status=3

our_iostat=`which iostat`
our_bc=`which bc`

if [ $# -gt 1 ]; then
  while getopts 'w:c:' OPTIONS; do
    case $OPTIONS in
      w) warn=$OPTARG;;
      c) crit=$OPTARG;;
    esac
  done
else
  echo $HELP
  exit 3
fi

tps_crit=`echo $crit | cut -d, -f1`
tps_warn=`echo $warn | cut -d, -f1`
kbread_crit=`echo $crit | cut -d, -f2`
kbread_warn=`echo $warn | cut -d, -f2`
kbwritten_crit=`echo $crit | cut -d, -f3`
kbwritten_warn=`echo $warn | cut -d, -f3`

for disk in `mount | grep ^/dev/ | awk '{print $1}'`; do
  tps=`$our_iostat $disk | grep -A1 Device | grep -v Device | awk '{print $2}'`
  kbread=`$our_iostat $disk | grep -A1 Device | grep -v Device | awk '{print $3}'`
  kbwritten=`$our_iostat $disk | grep -A1 Device | grep -v Device | awk '{print $4}'`
  
  if [ `echo "$tps >= $tps_crit" | $our_bc` == 1 ] || [ `echo "$kbread >= $kbread_crit" | $our_bc` == 1 ] || [ `echo "$kbwritten >= $kbwritten_crit" | $our_bc` == 1 ]; then
    echo 'CRITICAL'
    exit_status=2
  elif [ `echo "$tps >= $tps_warn" | $our_bc` == 1 ] || [ `echo "$kbread >= $kbread_warn" | $our_bc` == 1 ] || [ `echo "$kbwritten >= $kbwritten_warn" | $our_bc` == 1 ]; then
    echo 'WARNING'
    if [ !$exit_status=2 ]; then
      exit_status=1
    fi
  elif
    [ `echo "$tps < $tps_warn" | $our_bc` == 1 ] || [ `echo "$kbread <= $kbread_warn" | $our_bc` == 1 ] || [ `echo "$kbwritten < $kbwritten_warn" | $our_bc` == 1 ]; then
    echo 'OK'
    if [ !$exit_status=2 ] || [ !$exit_status=1 ]; then
      exit_status=0
    fi
  else
    echo 'LOLWHUT?'
    exit_status=3
  fi
  
  echo -n 'IO stats on disk' $disk '| TPS='$tps';'$tps_warn';'$tps_crit 'KBREAD='$kbread';'$kbread_warn';'$kbread_crit 'KBWRITTEN='$kbwritten';'$kbwritten_warn';'$kbwritten_crit' '
done

exit $exit_status
