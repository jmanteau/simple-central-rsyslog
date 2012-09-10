#!/bin/bash
# simple-central-rsyslog
# Recipe for a central rsyslog with log compression
# 
# jmanteau 04.09.2012
# 
# GPL
#
# Syntaxe: # su - -c "./simple-central-rsyslog.sh"
# Syntaxe: or # sudo ./simple-central-rsyslog.sh

VERSION="1.0"

#=============================================================================

# Variables globales
#-------------------

WGET="wget -m --no-check-certificate"
DATE=`date +"%Y%m%d%H%M%S"`
LOG_FILE="/tmp/simple-central-rsyslog-$DATE.log"
APT="aptitude -q -y"

# UPGRADE both of them !
LOGSTASHURL="http://semicomplete.com/files/logstash/logstash-1.1.1-monolithic.jar"
ELASTICSEARCHDEB="https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.19.8.deb"

LOGSTASHDIR="/opt/logstash"
LOGSTASHINIT="/etc/init.d/logstash"
LOGSTASHINITURL="https://raw.github.com/gist/3623477/377c1ec852a2d956f152e032a95644b3f17b5bb4/logstash.sh"
CONFRSYSLOG="https://raw.github.com/jmanteau/simple-central-rsyslog/master/rsyslog.conf"
CONFCRON="https://raw.github.com/jmanteau/simple-central-rsyslog/master/rsyslog-bzip2.txt"
REMOTELOGDIR="/var/log/remote/"

# Fonctions 
#---------------------------------

displaymessage() {
  echo "$*"
}

displaytitle() {
  displaymessage "------------------------------------------------------------------------------"
  displaymessage "$*"
  displaymessage "------------------------------------------------------------------------------"
}

displayerror() {
  displaymessage "$*" >&2
}

# Premier parametre: ERROR CODE
# Second parametre: MESSAGE
displayerrorandexit() {
  local exitcode=$1
  shift
  displayerror "$*"
  exit $exitcode
}

# Premier parametre: MESSAGE
# Autres parametres: COMMAND
displayandexec() {
  local message=$1
  echo -n "[In progress] $message"
  shift
  echo ">>> $*" >> $LOG_FILE 2>&1
  sh -c "$*" >> $LOG_FILE 2>&1
  local ret=$?
  if [ $ret -ne 0 ]; then
    echo -e "\r\e[0;31m   [ERROR]\e[0m $message"
  else
    echo -e "\r\e[0;32m      [OK]\e[0m $message"
  fi
  return $ret
}

# Start
#-------------------

# are you root ?
if [ $EUID -ne 0 ]; then
  displayerror 1 "You have to be root: # su - -c $0"
fi

# Log
echo "Starting" > $LOG_FILE

displaytitle "-- RSYSLOG"
displayandexec "Downloading rsyslog configuration" $WGET -O /etc/rsyslog.conf $CONFRSYSLOG
displayandexec "Downloading cron configuration to compress logs" $WGET -O /etc/cron.daily/rsyslog-bzip2 $CONFCRON
displayandexec "Adjusting rights" chmod +x /etc/cron.daily/rsyslog-bzip2
displayandexec "Making remote log dir" mkdir -p $REMOTELOGDIR
displayandexec "Restarting rsyslog" /etc/init.d/rsyslog restart
displaytitle "-- Done"

displaytitle "-- LOGSTASH" 
displayandexec "Making Logstash dirs" mkdir -p $LOGSTASHDIR && mkdir /var/log/logstash && mkdir /etc/logstash
displayandexec "Downloading Logstash jar" $WGET -O $LOGSTASHDIR/logstash.jar $LOGSTASHURL
displayandexec "Installing Java" $APT install default-jre
displayandexec "Downloading logstash init.d" $WGET -O $LOGSTASHINIT $LOGSTASHINITURL
displayandexec "Adjusting rights" chmod +x $LOGSTASHINIT
displayandexec "Starting at boot" update-rc.d logstash defaults

# In case of distributed elasticsearch
#displaytitle "-- ELASTICSEARCH"
#displayandexec "Downloading deb" $WGET $ELASTICSEARCHDEB
#displayandexec "Installing Elasticsearch from deb" dpkg -i elasticsearch*.deb


displaytitle "-- KIBANA"
displayandexec "Installing requirement" $APT install git ruby rubygems apache2 curl libcurl3-dev
displayandexec "Installing Ruby stuff" export PATH=/var/lib/gems/1.8/bin/:${PATH} && gem install bundler
displayandexec "Downloading Kibana" cd /var/www/ &&  git clone --branch=kibana-ruby https://github.com/rashidkpc/Kibana.git 
displayandexec "Installing Ruby gems" cd /var/www/Kibana && bundle install
echo "End" >> $LOG_FILE


