#!/bin/bash

echo -n "Enter your username and press [ENTER]: "
read USERID
echo -n "Enter your password and press [ENTER]: "
read PASSWD
echo -n "Enter desired port and press [ENTER]: "
read PORT
echo -n "Enter download directory (e.g /root/ ) and press [ENTER]: "
read DOWNLOADDIR
mkdir -p $DOWNLOADDIR

echo -n "Would you like to enable temporary directory folder? [y/N] "
read TEMPQ
if [ "$TEMPQ" == "" ] || [ "$TEMPQ" == "n" ] || [ "$TEMPQ" == "N" ] ; then
    TEMP="false"
    DOWNLOADDIRTEMP=$DOWNLOADDIR
elif [ "$TEMPQ" == "y" ] || [ "$TEMPQ" == "Y" ] ; then
    TEMP="true"
    echo -n "Enter your temporary download directory (e.g /root/ ) and press [ENTER]: "
    read DOWNLOADDIRTEMP
    mkdir -p $DOWNLOADDIRTEMP
fi

( [ -n "$(grep CentOS /etc/issue)" ] \
  && ( yum install gcc g++ make vim pam-devel tcp_wrappers-devel unzip httpd-tools -y ) ) \
  || ( [ -n "$(grep 'Debian' /etc/issue)" ] \
  && ( apt-get update;apt-get install gcc g++ ca-certificates libcurl4-openssl-dev libssl-dev pkg-config build-essential checkinstall intltool -y )) \
  || ( [ -n "$(grep 'Ubuntu' /etc/issue)" ] \
  && ( apt-get update;apt-get install build-essential automake autoconf libtool pkg-config intltool libcurl4-openssl-dev libssl-dev libglib2.0-dev libevent-dev libminiupnpc-dev libappindicator-dev ))\
  || exit 0

mkdir -p ~/tmp/pt
cd ~/tmp/pt

wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
tar xzf libevent-*.tar.gz
wget https://github.com/transmission/transmission-releases/raw/master/transmission-2.94.tar.xz -O transmission.tar.xz
xz -d transmission.tar.xz
tar -xvf  transmission*.tar

cd libevent-*/
CFLAGS="-Os -march=native" ./configure && make && make install

cd ../transmission*/
CFLAGS="-Os -march=native" ./configure && make && make install

rm ~/tmp/pt -rf
ln -s /usr/local/lib/libevent-2.1.so.6 /usr/lib/libevent-2.1.so.6
 
transmission-daemon
ps -ef | grep 'transmission-daemon' \
       | grep -v 'grep' | awk '{print $2}'\
       | while read pid;do kill -9 $pid >/dev/null 2>&1 ;done

mkdir -p ~/.config/transmission-daemon/
cat > ~/.config/transmission-daemon/settings.json <<EOF
{
    "alt-speed-down": 50,
    "alt-speed-enabled": false,
    "alt-speed-time-begin": 540,
    "alt-speed-time-day": 127,
    "alt-speed-time-enabled": false,
    "alt-speed-time-end": 1020,
    "alt-speed-up": 50,
    "bind-address-ipv4": "0.0.0.0",
    "bind-address-ipv6": "::",
    "blocklist-enabled": false,
    "blocklist-url": "http://www.example.com/blocklist",
    "cache-size-mb": 128,
    "dht-enabled": true,
    "download-dir": "$DOWNLOADDIR",
    "download-queue-enabled": true,
    "download-queue-size": 2,
    "encryption": 1,
    "idle-seeding-limit": 1,
    "idle-seeding-limit-enabled": true,
    "incomplete-dir": "$DOWNLOADDIRTEMP",
    "incomplete-dir-enabled": $TEMP,
    "lpd-enabled": false,
    "message-level": 2,
    "peer-congestion-algorithm": "",
    "peer-id-ttl-hours": 6,
    "peer-limit-global": 200,
    "peer-limit-per-torrent": 50,
    "peer-port": 51413,
    "peer-port-random-high": 65535,
    "peer-port-random-low": 49152,
    "peer-port-random-on-start": false,
    "peer-socket-tos": "default",
    "pex-enabled": true,
    "port-forwarding-enabled": true,
    "preallocation": 1,
    "prefetch-enabled": true,
    "queue-stalled-enabled": true,
    "queue-stalled-minutes": 30,
    "ratio-limit": 0,
    "ratio-limit-enabled": true,
    "rename-partial-files": true,
    "rpc-authentication-required": true,
    "rpc-bind-address": "0.0.0.0",
    "rpc-enabled": true,
    "rpc-host-whitelist": "",
    "rpc-host-whitelist-enabled": true,
    "rpc-password": "$PASSWD",
    "rpc-port": $PORT,
    "rpc-url": "/transmission/",
    "rpc-username": "$USERID",
    "rpc-whitelist": "127.0.0.1",
    "rpc-whitelist-enabled": false,
    "scrape-paused-torrents-enabled": true,
    "script-torrent-done-enabled": false,
    "script-torrent-done-filename": "",
    "seed-queue-enabled": false,
    "seed-queue-size": 10,
    "speed-limit-down": 100,
    "speed-limit-down-enabled": false,
    "speed-limit-up": 1,
    "speed-limit-up-enabled": true,
    "start-added-torrents": true,
    "trash-original-torrent-files": false,
    "umask": 7,
    "upload-slots-per-torrent": 14,
    "utp-enabled": true
}
EOF

chown -R debian-transmission:debian-transmission "$DOWNLOADDIR"
if [ "$TEMP" == "true" ] ; then
chown -R debian-transmission:debian-transmission "$DOWNLOADDIRTEMP"
fi
sleep 3
transmission-daemon
clear

#Color Variable
CSI=$(echo -e "\033[")
CEND="${CSI}0m"
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"
CQUESTION="$CMAGENTA"
CWARNING="$CRED"
CMSG="$CCYAN"
#Color Variable

if [ -n "$(ps -ef | grep 'transmission-daemon' | grep -v 'grep' | awk '{print $2}')" ];then
IP=$( ifconfig | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})' )
EIP=$( curl icanhazip.com )
cat <<EOF
${CCYAN}+-----------------------------------------+$CEND
${CGREEN}  transmission Install Done. $CEND
${CCYAN}+-----------------------------------------+$CEND
${CGREEN}  Version:       $CMAGENTA 2.94$CEND
${CGREEN}  User:          $CMAGENTA ${USERID}$CEND
${CGREEN}  Passwd:        $CMAGENTA ${PASSWD}$CEND
${CGREEN}  WebPanel:      $CMAGENTA ${IP}:${PORT}$CEND
${CGREEN}  Ext WebPanel:  $CMAGENTA ${EIP}:${PORT}$CEND
${CCYAN}+_________________________________________+$CEND
EOF
else
echo -e "\033[1;31m transmission Install Failed! \033[0m"
fi
exit 0
