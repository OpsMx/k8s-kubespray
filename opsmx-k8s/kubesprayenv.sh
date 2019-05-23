#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan


#### Ansible Installation: In current setup we are using HAProxy system as our launch machine

## Step to Create Virtual environment and Install Ansible in launch machine
echo " .... Setting up virtual environment for installing ansible playbook .........."

echo " .... To install ansible setting up pre-requisites on the machine to initiate kubespray .........."
sudo apt-get install -y software-properties-common 
echo " .... Adding ansible repository to the local repository list .........."
sudo apt-add-repository ppa:ansible/ansible 
echo " .... Installing ansible on the machine to initiate kubespray .........."
sudo apt-get update && sudo apt-get install -y ansible python-netaddr 
sudo apt-get update && sudo apt-get install -y python-pip  virtualenv
sudo pip install -y ansible python-netaddr python-jinja2

echo ".. Performing git clone in launch machine....." >> /dev/null 2>&1
git clone https://github.com/OpsMx/k8s-kubespray


	
