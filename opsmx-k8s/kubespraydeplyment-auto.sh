#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan


#### Ansible Installation: In current setup we are using HAProxy system as our launch machine

## Kubect binary installation
echo " .......Checking kubectl binary available in the system/node to deploy spinnaker in k8s-cluster..."
if [ -x /usr/bin/local/kubectl ]; then
	echo " kubectl binary is available for the further process"
else
	echo " kubectl is not installed .. System starts to install kubectl binary.."
	
	echo " .......Downloading kubectl binary from kubernetes-release..."
	curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

	echo " .......Changing kubectl binary to executable mode..."
	chmod +x ./kubectl

	echo " .......Moving kubectl binary to /usr/local/bin folder..."
	sudo mv ./kubectl /usr/local/bin/kubectl
fi

## Helm binary installation
echo " .......Checking helm binary available in the system/node to deploy spinnaker in k8s-cluster..."
if [ -x /usr/local/bin/helm ]; then
	echo " helm binary is available for the further process"
else
	echo " helm is not installed .. System starts to install helm binary.."
	
	echo " .......Downloading helm binary ..."
	curl -sLO https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz

	echo " .......Untaring the helm gz..."
	tar xfz helm-v2.13.1-linux-amd64.tar.gz

	echo " .......Moving helm binary to /usr/local/bin folder..."
	sudo mv linux-amd64/helm /usr/local/bin/helm
fi

echo".. Initiating k8s-cluster settup from launch machine....."
ansible-playbook -b k8s-kubespray/kubespray/cluster.yml

echo ".. Wait for completion of deployment...."

echo ".. Copy kubeconfig file from master1 to launch machine ....."
read -p "  [****] Enter the master1 private ip where to copy kubeconfig file to launch mahine :" master1_ip
echo ".. Copying admin.conf file from master1 to launch machine....."
sudo scp $master1_ip:/etc/kubernetes/admin.conf .
echo ".. Renaming admin.conf file to config in launch machine....."
sudo mv admin.conf config
echo ".. Creating .kube folder in launch machine to copy config file....."
sudo mkdir ~/.kube
echo ".. Copying config file from current folder to .kube folder in launch machine....."
sudo mv config ~/.kube/config
read -p "  [****] Enter the username with to run kubectl command in launch machine :" username
echo ".. Changing ownership of .kube/config file in launch machine as the user....."
sudo chown $username:$username ~/.kube/config

echo ".. Verifying deployment of k8s-cluster from launch machine ....."
echo ".. Displaying master and node details from the deployed of k8s-cluster from launch machine ....."
kubectl get node -o wide
echo ".. Displaying all the namespaces details from the deployed of k8s-cluster from launch machine ....."
kubectl get namespace
echo ".. Displaying all the pod details from the deployed of k8s-cluster from launch machine ....."
kubectl get pods --all-namespaces
echo ".. Displaying all details from the deployed of k8s-cluster from launch machine ....."
kubectl get all --all-namespaces

