#!/bin/bash

# Require root access
if [[ ("$UID" != 0) ]]; then
    echo "Root access is required for modifying iptables"
    exit 1
fi
cd $(realpath $(dirname $0))

# Check for tooling and ovpn files
function checkForTool {
    which $1 &> /dev/null
    if [[ $? != 0 ]];then
        echo "Required tool '$1' not found, please install it first"
        exit 1
    fi
}
checkForTool iptables
checkForTool nmcli
if [ "$#" -gt 1 ];then
    echo "Too many arguments, only takes one optional argument (ovpn file)"
    exit 1
fi
if [ "$#" == 1 ];then
    vpnfile=$1
else
    ls *.ovpn &> /dev/null
    if [[ $? != 0 ]];then
        echo "Please store any .ovpn file next to this script to continue"
        exit 1
    fi
    checkForTool fzf
    vpnfile=`ls -1 *.ovpn | fzf`
fi
vpnname=`basename ${vpnfile%.*}`

# Check for existing configs
nmcli connection show $vpnname >/dev/null
if [[ $? != 0 ]]; then
    # Import openvpn config file to the network manager
    runuser -u `logname` -- nmcli connection import type openvpn file $vpnfile
    username=`sed -n '1p' < credentials.txt`
    password=`sed -n '2p' < credentials.txt`
    runuser -u `logname` -- nmcli connection modify $vpnname +vpn.data username=$username
    runuser -u `logname` -- nmcli connection modify $vpnname +vpn.secrets password=$password
fi

# Block connection without VPN
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o tun0 -d 0/0 -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j DROP
iptables -A OUTPUT -p tcp --dport 53 -j DROP
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
iptables -A OUTPUT -d 100.64.0.0/10 -j ACCEPT
for ip in `grep "remote " $vpnfile | awk '{print $2}' | uniq`; do
    iptables -A OUTPUT -d $ip/32 -j ACCEPT
done
iptables -A OUTPUT -j REJECT
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables-save > /etc/sysconfig/iptables
