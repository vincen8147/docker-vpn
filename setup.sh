#!/bin/bash

docker ps
echo
echo
read -p 'Enter the container ID for the ljishen/pivpn image:' ID
echo
docker exec --privileged ${ID} /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE \
  && /sbin/iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT \
  && /sbin/iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
echo
echo Exporting filesystem to pivpn_keys.tar
docker export ${ID} > pivpn_keys.tar
echo
echo Stopping the ljishen/pivpn container.
docker container stop ${ID}
echo
echo Importing pivpn_keys.tar as pivpn_keys image.
docker import pivpn_keys.tar pivpn_keys
echo
echo Done.
echo
