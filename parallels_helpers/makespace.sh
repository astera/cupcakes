#!/bin/bash

# Get rid of clients' logfiles (already processed by awstats or alike) under a
# set of Plesk environments inside multiple Virtuozzo VMs fast.

for vm in `vzlist -o veid -H | tail +2` ; do
    echo 'Looking for client logs to nuke in' $vm

    for path in `find /vz/root/$vm/var/www/vhosts/*/statistics/logs/ -name *.processed -size +409600` ; do
        echo 'Wiping' $path
        echo '' > $path
    done
done

echo 'FOR SCIENCE \o'
