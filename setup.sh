#!/bin/bash

docker ps
echo
echo
read -p 'Enter the container ID for the ljishen/pivpn image: ' ID
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
