# docker-vpn
Docker VPN for Raspberrypi

## Introduction

I found that I needed a predicable and repeatable way to get my VPN service
running on my Raspberry PI.  I found [PIVPN](http://www.pivpn.io/) a while ago.  It worked great for a while, until I did a `apt-get upgrade`.  Then it stopped
working.  Docker on the Raspberrypi to the rescue!<sup>[1](#f1)</sup>

I came across [pivpn-docker](https://github.com/ljishen/pivpn-docker).  This
seemed like the perfect setup.  One issue though.  Docker will always start
from scratch when the container is restarted.  This means that
[pivpn-docker](https://github.com/ljishen/pivpn-docker) regenerates the keys
and certificates. This makes any distributed client ovpn file obsolete.

The instructions and scripts I've created here will allow you to reuse the same
generated setup every time your PI is restarted.

## Setup
All these instructions assume you are the root user on a Raspberrypi and
you have cloned this project to `/opt`.
```
# sudo su -
# cd /opt
# git clone https://github.com/vincen8147/docker-vpn.git
# cd docker-vpn
```

First you need to run the
[pivpn-docker](https://github.com/ljishen/pivpn-docker)
container to get all VPN goodies created.  This will take a while to run as it
generates your keys; like 20 minutes<sup>[2](#f2)</sup>.

```
# docker run -ti --rm --privileged ljishen/pivpn
```
Wait until you see `::: Start PiVPN Service`

In a new terminal run the following to setup our VPN docker image that will
have your keys saved.
```
# sudo su -
# cd /opt/docker-vpn
# bash setup.sh
```

The setup script will:
1. [Export](https://docs.docker.com/engine/reference/commandline/export/) the filesystem of the container.    
1. Stop the ljishen/pivpn container.
1. [Import](https://docs.docker.com/engine/reference/commandline/import/)
the file as a new image to use as our VPN service.

You should now see your Docker image in the images list.
```
# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
pivpn_keys          latest              6defdb2682c3        10 seconds ago      194MB
ljishen/pivpn       latest              915e62685057        4 months ago        242MB
```
## Running your service.
You can now start your VPN service in a container.
```
# docker-compose up -d pivpn
```
The service should be up and running fairly quickly.  `docker ps` should list your container.

You now need to create some ovpn files for the clients of your VPN service.
Use the `add.sh` script to generate a new ovpn client file.
```
# /bin/bash add.sh

Client Name: myfirstclient
Password:

Adding client myfirstclient...

spawn ./easyrsa build-client-full myfirstclient

Note: using Easy-RSA configuration from: ./vars
rand: Use -help for summary.
Generating a 2048 bit RSA private key
.................................................................................................................................................+++
..+++
writing new private key to '/etc/openvpn/easy-rsa/pki/private/myfirstclient.key.R6rnFbkl4D'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
Using configuration from /etc/openvpn/easy-rsa/openssl-1.0.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'myfirstclient'
Certificate is to be certified until Sep 19 18:51:15 2028 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated
spawn openssl rsa -in pki/private/myfirstclient.key -des3 -out pki/private/myfirstclient.key
Enter pass phrase for pki/private/myfirstclient.key:
writing RSA key
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
Client's cert found: myfirstclient.crt
Client's Private Key found: myfirstclient.key
CA public Key found: ca.crt
tls-auth Private Key found: ta.key


========================================================
Done! myfirstclient.ovpn successfully created!
myfirstclient.ovpn was copied to:
  /home/pivpn/ovpns
for easy transfer. Please use this profile only on one
device and create additional profiles for other devices.
========================================================
```
You should now find the generated ovpn file in the `/home/pi/ovpns` folder on
the local filesystem.
```
# ls -al /home/pi/ovpns/
total 24
drwxr-xr-x 2 root root 4096 Sep 22 20:36 .
drwxr-xr-x 4 pi   pi   4096 Sep 22 14:01 ..
-rw-r--r-- 1  999 root 5034 Sep 22 20:36 myfirstclient.ovpn
```
Now you can distribute the `myfirstclient.ovpn` to your VPN clients and enjoy
some secure communications.

## Starting the container on system startup.
Copy the `docker-compose-app.service` file to `/etc/systemd/system`
```
# cp docker-compose-app.service /etc/systemd/system/
```
Enable the service:
```
systemctl enable docker-compose-app
```

## Footnotes
1. <a name="f1">&nbsp;</a> [How to install Docker on the pi.](
  https://medium.freecodecamp.org/the-easy-way-to-set-up-docker-on-a-raspberry-pi-7d24ced073ef)
1. <a name="f2">&nbsp;</a>
"Linux is only free if your time has no value". Jamie Zawinski
