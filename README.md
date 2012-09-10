simple-central-rsyslog
======================

Recipe for a central rsyslog with log compression.
Listen on port 514
The logs are under the dir /var/log/remote/$HOSTNAME/$YEAR/$MONTH/$DAY-log
Tested on a Debian Squeeze. Should work on others distros.

Usage:
\# wget --no-check-certificatehttps://raw.github.com/jmanteau/simple-central-rsyslog/master/simple-central-rsyslog.sh
\# bash simple-central-rsyslog.sh