#!/bin/bash

for vm in `vzlist -o veid -H | tail +2` ; do
    echo 'Looking for the typically spammed SQLite database on VEID' $vm
    for file in `find /vz/root/$vm/var/www/vhosts/*/httpdocs -name sb_modules.db -size +102400` ; do
        echo $file
    done
done

