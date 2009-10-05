#!/bin/bash

# ohai thar, plz lemme terminat0r ur delicious soup queriez that ran longer than 10 min, kthxbai

FILE=""

if [ -e $FILE ]; then
    echo `date` 'Running migration' >> pslackql_huntreport.txt
else 
    psql -c "SELECT NOW(),procpid,NOW()-query_start,current_query,pg_cancel_backend(procpid) FROM pg_stat_activity WHERE current_query LIKE "SELECT%" AND NOW()-query_start>TIME '00:10:00';" -t postgres >> pslackql_huntreport.txt
fi