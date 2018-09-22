#!/bin/bash

read -p 'Client Name: ' CLIENT_NAME
read -sp 'Password: ' CLIENT_PASS
echo
echo
echo Adding client $CLIENT_NAME...
echo
docker exec dockervpn_pivpn_1 /usr/local/bin/pivpn -a -n "${CLIENT_NAME}" -p "${CLIENT_PASS}" || true
echo
echo Your ovpn file should be found in "/home/pi/ovpns".
chown pi:pi /home/pi/ovpns/${CLIENT_NAME}.ovpn
