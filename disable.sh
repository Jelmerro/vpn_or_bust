#!/bin/bash

# Require root access
if [[ ("$UID" != 0) ]]; then
    echo "Root access is required for this installation"
    exit 1
fi

# Flush iptables and reset policies
iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
