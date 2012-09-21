simple-central-rsyslog
======================

Recipe for a central rsyslog with log compression.
Listen on port 514
The logs are under the dir /var/log/remote/$HOSTNAME/$YEAR/$MONTH/$DAY-log
Logstash is configured to look inside the dir. Kibana is used as a frontend.
Tested on a Debian Squeeze. 

**Usage:**  

   \# wget --no-check-certificate https://raw.github.com/jmanteau/simple-central-rsyslog/master/simple-central-rsyslog.sh  
   \# bash simple-central-rsyslog.sh