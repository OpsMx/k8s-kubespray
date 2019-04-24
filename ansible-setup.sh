#!/bin/bash


sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
sudo apt-get install -y python
sudo apt-get install -y python-netaddr
sudo apt-get install -y jinja2



