#!/bin/bash
# simple-central-rsyslog
# Recipe for a central rsyslog with log compression
#
# jmanteau 03.09.2012
# 
# GPL
#
# Syntaxe: # su - -c "./simple-central-rsyslog.sh"
# Syntaxe: or # sudo ./simple-central-rsyslog.sh

VERSION="1.0"

#=============================================================================

# Variables globales
#-------------------

HOME_PATH=`grep $USERNAME /etc/passwd | cut -d: -f6`
APT_GET="apt-get -q -y --force-yes"
WGET="wget -m --no-check-certificate"
DATE=`date +"%Y%m%d%H%M%S"`
LOG_FILE="/tmp/simple-central-rsyslog-$DATE.log"


CONFRSYSLOG="https://raw.github.com/jmanteau/simple-central-rsyslog/master/rsyslog.conf"
CONFCRON="https://raw.github.com/jmanteau/simple-central-rsyslog/master/rsyslog-bzip2.txt"
REMOTELOGDIR="/var/log/remote/"

# Fonctions utilis�es par le script
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
  echo -n "[En cours] $message"
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

# Debut du programme
#-------------------

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  displayerror 1 "Le script doit �tre lanc� en root: # su - -c $0"
fi

# Cr�ation du fichier de log
echo "Debut du script" > $LOG_FILE

displaytitle "-- Installation des fichiers et red�marrage du daemon"
displayandexec "T�l�chargement de la configuration rsyslog" $WGET -O /etc/apt/sources.list $CONFRSYSLOG
displayandexec "T�l�chargement de la configuration cron pour la compression" $WGET -O /etc/apt/sources.list $CONFCRON
displayandexec "Cr�ation du r�pertoire de log $REMOTELOGDIR" mkdir -p $REMOTELOGDIR
displayandexec "Red�marrage de rsyslog" /etc/init.d/rsyslog restart
displaytitle "-- Fin d'installation"

echo "Fin du script" >> $LOG_FILE


