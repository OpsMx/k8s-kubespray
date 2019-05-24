#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan


#### Ansible Installation: In current setup we are using HAProxy system as our launch machine
node_list=("x.x.x.x" "x.x.x.x")

# Installing python is required to test ansible ping on each node .
function install_prerequiste() {
  local -n nodelist=$1
  for ((i=0;i<${#nodelist[@]};++i))
  do
    echo ""
    echo "************* Connecting to ${nodelist[i]} ************"
    # Download python on each target node
    echo "Started installing python..."
    ssh -A ${nodelist[i]} "sudo apt-get update && sudo apt-get install -y python python-netaddr"
  done
}

## Step to Create Virtual environment and Install Ansible in launch machine
echo " .... Setting up virtual environment for installing ansible playbook .........."

echo " .... To install ansible setting up pre-requisites on the machine to initiate kubespray .........."
sudo apt-get install -y software-properties-common 
echo " .... Adding ansible repository to the local repository list .........."
sudo apt-add-repository ppa:ansible/ansible 
echo " .... Installing ansible on the machine to initiate kubespray .........."
sudo apt-get update && sudo apt-get install -y ansible python-netaddr 
echo " .... Installing python-pip and virtualenv on the machine to initiate kubespray .........."
sudo apt-get update && sudo apt-get install -y python-pip  virtualenv

echo "Started installing pre-requiste on each node ..."
install_prerequiste node_list
echo "Installed pre-requiste successfully"


	
