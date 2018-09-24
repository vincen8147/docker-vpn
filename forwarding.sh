#!/bin/bash

# based on https://raspberrypi.stackexchange.com/questions/48307/sharing-the-pis-wifi-connection-through-the-ethernet-port
# allow forwarding traffic coming from tun0 to get internet from eth0.
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
