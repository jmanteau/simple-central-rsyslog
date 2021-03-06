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
LOGSTASHINITURL="https://raw.github.com/jmanteau/simple-central-rsyslog/master/logstash"
LOGSTASHCONF="https://raw.github.com/jmanteau/simple-central-rsyslog/master/logstash.conf"
LOGSTASHCLEANER="https://raw.github.com/jmanteau/simple-central-rsyslog/master/logstash_index_cleaner.py"
CONFRSYSLOG="https://raw.github.com/jmanteau/simple-central-rsyslog/master/rsyslog.conf"
CONFCRON="https://raw.github.com/jmanteau/simple-central-rsyslog/master/rsyslog-bzip2.txt"
NGINXPASSENGER="https://raw.github.com/jmanteau/simple-central-rsyslog/master/nginx-passenger.conf"
NGINXKIBANA="https://raw.github.com/jmanteau/simple-central-rsyslog/master/vhost-kibana.conf"
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


# displaytitle "-- KIBANA"
# displayandexec "Installing requirement" $APT install git ruby-full rubygems curl libcurl3-dev ruby1.9.1-full rubygems1.9.1
# displaymessage "Make Ruby 1.9 default" 
##install ruby1.8 & friends with priority 500
# update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.8 500 \
# --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
# /usr/share/man/man1/ruby.1.8.gz \
# --slave   /usr/bin/ri ri /usr/bin/ri1.8 \
# --slave   /usr/bin/irb irb /usr/bin/irb1.8
##install ruby1.9.1 & friends with priority 600 and make them default
# update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 600 \
# --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
# /usr/share/man/man1/ruby.1.9.1.1.gz \
# --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
# --slave   /usr/bin/irb irb /usr/bin/irb1.9.1
# displayandexec "Installing Ruby stuff" export PATH=/var/lib/gems/1.9/bin/:${PATH} && gem install bundler jls-grok
# echo "#dotdeb nginx"  > /etc/apt/sources.list.d/dotdeb.list
# echo "deb http://packages.dotdeb.org squeeze all" >> /etc/apt/sources.list.d/dotdeb.list
# echo "deb-src http://packages.dotdeb.org squeeze all" >> /etc/apt/sources.list.d/dotdeb.list
# displayandexec "Adding dotdeb repo" wget http://www.dotdeb.org/dotdeb.gpg
# cat dotdeb.gpg | apt-key add - 
# displayandexec "Installing nginx and passenger" aptitude update && $APT install nginx-passenger
# displayandexec "Downloading Nginx Passenger conf" $WGET -O /etc/nginx/nginx-passenger.conf $NGINXPASSENGER
# displayandexec "Downloading Kibana vhost conf" $WGET -O /etc/nginx/sites-enabled/vhost-kibana.conf $NGINXKIBANA
# displayandexec "Downloading Kibana" mkdir /var/www && cd /var/www/ &&  git clone --branch=kibana-ruby https://github.com/rashidkpc/Kibana.git 
# displayandexec "Installing Ruby gems" cd /var/www/Kibana && bundle install
# displayandexec "Adjusting web dir right" chown -R www-data:www-data /var/www/Kibana/
# displayandexec "Restarting Nginx"  service nginx restart

displaytitle "-- KIBANA"
displayandexec "Downloading Kibana"  cd /var/www/ &&  git clone --branch=kibana-ruby https://github.com/rashidkpc/Kibana.git 
displayandexec "Installing Ruby gems" cd /var/www/Kibana && bundle install
displayandexec "Adjusting web dir right" chown -R www-data:www-data /var/www/Kibana/
displayandexec "Restarting Nginx"  /etc/init.d/apache2 force-reload


apt-get install 

echo "End" >> $LOG_FILE

