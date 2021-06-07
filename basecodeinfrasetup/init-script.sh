#!/bin/bash
apt update
apt install ansible -y
a=`sed "s/[^a-zA-Z0-9]//g" <<< $(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%*()-+' | fold -w 4 | head -n 1)`
sudo hostnamectl set-hostname jenkis-$a && bash
