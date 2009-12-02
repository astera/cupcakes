#!/bin/bash

# Oh yes. It most definitely _is_ just brutally simple...

if ! ps -C $SERVICE > /dev/null;
then
    /etc/init.d/$SERVICE restart
fi

# Or, the smart one-line-example to put in your much beloved crontab:
# if ! ps -C $SERVICE > /dev/null; then /etc/init.d/$SERVICE restart; fi

