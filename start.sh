#!/bin/bash
killall php-fpm
rsyslogd
cron

tail -f /var/log/syslog /var/log/cron.log
