#!/bin/bash


sudo apt-get update
sudo apt install -y nfs-kernel-server

sudo mkdir -p /home/public
sudo chown nobody:nogroup /home/public
sudo chmod 777 /home/public

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

