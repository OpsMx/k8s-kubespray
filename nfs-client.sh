#!/bin/bash

NFS_SERVER_IP=$1

sudo apt-get update
sudo apt-get install nfs-common
showmount -e $NFS_SERVER_IP
