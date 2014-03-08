#!/bin/bash
DOWNLOADDIR="$HOME/Download"
USERID="tranmission"
PASSWD="88888888"
PORT="8008"

mkdir -p $DOWNLOADDIR

( [ -n "$(grep CentOS /etc/issue)" ] \
  && ( yum install gcc g++ make vim pam-devel tcp_wrappers-devel unzip httpd-tools -y ) ) \
  || ( [ -n "$(grep 'Debian' /etc/issue)" ] \
  && ( apt-get update;apt-get install gcc g++ ca-certificates libcurl4-openssl-dev libssl-dev pkg-config build-essential checkinstall intltool -y )) \
  || ( [ -n "$(grep 'Ubuntu' /etc/issue)" ] \
  && ( apt-get update;apt-get install build-essential automake autoconf libtool pkg-config intltool libcurl4-openssl-dev libglib2.0-dev libevent-dev libminiupnpc-dev libminiupnpc5 libappindicator-dev ))\
  || exit 0

mkdir /tmp/pt
cd /tmp/pt

wget https://github.com/downloads/libevent/libevent/libevent-1.4.14b-stable.tar.gz
tar xzf libevent-*.tar.gz
wget http://download-origin.transmissionbt.com/files/transmission-2.01.tar.xz -O transmission.tar.xz
xz -d transmission.tar.xz
tar -xvf  transmission*.tar

cd libevent-*
CFLAGS="-Os -march=native" ./configure && make && make install

cd ../transmission*
CFLAGS="-Os -march=native" ./configure && make && make install

rm /tmp/pt -rf
ln -s /usr/local/lib/libevent-1.4.so.2 /usr/lib/libevent-1.4.so.2
 
transmission-daemon
pkill transmission-daemon

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
    "dht-enabled": false, 
    "download-dir": "$DOWNLOADDIR", 
    "encryption": 1, 
    "incomplete-dir": "$DOWNLOADDIR", 
    "incomplete-dir-enabled": false, 
    "lazy-bitfield-enabled": true, 
    "lpd-enabled": false, 
    "message-level": 2, 
    "open-file-limit": 32, 
    "peer-limit-global": 240, 
    "peer-limit-per-torrent": 60, 
    "peer-port": 51413, 
    "peer-port-random-high": 65535, 
    "peer-port-random-low": 49152, 
    "peer-port-random-on-start": false, 
    "peer-socket-tos": 0, 
    "pex-enabled": true, 
    "port-forwarding-enabled": true, 
    "preallocation": 1, 
    "proxy": "", 
    "proxy-auth-enabled": false, 
    "proxy-auth-password": "", 
    "proxy-auth-username": "", 
    "proxy-enabled": false, 
    "proxy-port": 80, 
    "proxy-type": 0, 
    "ratio-limit": 2.0000, 
    "ratio-limit-enabled": false, 
    "rename-partial-files": true, 
    "rpc-authentication-required": true, 
    "rpc-bind-address": "0.0.0.0", 
    "rpc-enabled": true, 
    "rpc-password": "$PASSWD", 
    "rpc-port": $PORT, 
    "rpc-username": "$USERID", 
    "rpc-whitelist": "127.0.0.1", 
    "rpc-whitelist-enabled": false, 
    "script-torrent-done-enabled": false, 
    "script-torrent-done-filename": "", 
    "speed-limit-down": 100, 
    "speed-limit-down-enabled": false, 
    "speed-limit-up": 100, 
    "speed-limit-up-enabled": false, 
    "start-added-torrents": true, 
    "trash-original-torrent-files": false, 
    "umask": 18, 
    "upload-slots-per-torrent": 14
}
EOF

transmission-daemon
clear
exit 0
