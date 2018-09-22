#!/bin/bash

read -p 'Client Name: ' CLIENT_NAME
echo
echo Removing client $CLIENT_NAME...
echo
docker exec vpndocker_pivpn_1 /usr/local/bin/pivpn -r "${CLIENT_NAME}"
