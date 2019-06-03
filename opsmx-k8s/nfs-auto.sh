#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan

# Add the Cluster node private-IPs which are going to be NFS client
node_list=("10.170.0.11" "10.170.0.8" "10.170.0.9")

# This is required to be executed for each minion node.
function nfs_client() {
  local -n nodelist=$1
  for ((i=0;i<${#nodelist[@]};++i))
  do
    echo ""
    echo "************* Connecting to ${nodelist[i]}  *************"
    # Download nfs-common on each target node
    echo "Started installing nfs-common..."
    ssh -A ${nodelist[i]} "sudo apt-get update && sudo apt-get install -y nfs-common"
    echo "Started verifying nfs connection between client and server..."
    ssh -A ${nodelist[i]} "showmount -e $nfs_server_ip"
  done
}

echo "Installing NFS in the K8s Multi master Multi node/worker Cluster ..."

echo "Installing helm in the launch machine"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
status=$?
if test $status -eq 0
then
  echo "The helm is created successfully"
elif test $status -eq 1
then
  echo "'helm' is already exist!"
else
  echo "Failed to install helm!"
  exit
fi

echo "Create a service account and then bind the cluster-admin role to the service account"
kubectl create serviceaccount tiller --namespace kube-system
status=$?
if test $status -eq 0
then
  echo "Created service account successfully"
elif test $status -eq 1
then
  echo "'service account' is already exist!"
else
  echo "Failed to create service account!"
  exit
fi

echo "Binding the cluster-admin role to the service account"
kubectl create clusterrolebinding tiller-deploy --clusterrole cluster-admin --serviceaccount kube-system:tiller
status=$?
if test $status -eq 0
then
  echo "Created the CluterRoleBinding successfully for admin"
elif test $status -eq 1
then
  echo "The ClusterRole is already exist for admin!"
else
  echo "Failed to create the ClusterRole for admin!"
fi

echo "Installing tiller ..."
helm init --service-account tiller
status=$?
if test $status -eq 0
then
  echo "Installed tiller successfully"
elif test $status -eq 1
then
  echo "The tiller installation is already exist!"
else
  echo "Failed to install tiller!"
fi

## Setting up NFS server and installing nfs packages

echo ".......... Starting to install nfs server ......"
sudo apt-get update && sudo apt-get install -y nfs-kernel-server
echo ".......... Creating a folder for nfs share ......"
printf "\n"
read -p " Enter NFS Folder name which need to be created ( example : /home/nfsshare ): " nfsfolder
echo ".. NFS folder is creating..."
read -p  " Enter the private ip range with which the nfs share folder will be exposed ( for example 10.0.0.0/18): " nfs_share_iprange
echo " updating ip range of client to be exposed "
sudo mkdir -p $nfsfolder
echo ".......... Changing ownership and permission to folder for nfs share ......"
sudo chown nobody:nogroup $nfsfolder	
sudo chmod 777 $nfsfolder
echo ".......... Updating the exports file with nfs share folder details ......"
# sudo su
sudo echo "$nfsfolder $nfs_share_iprange(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
# exit
echo ".......... Checking the NFS configuration details ......"
sudo exportfs -a	
sudo exportfs
echo ".......... NFS Server configutaion sucessfully completed ......"

echo ".......... NFS client provisioning setup in the k8s-cluster ......"
read -p  " Enter NFS server ip ( example : 10.165.0.56 ): " nfs_server_ip



echo "Started installing nfs-common on each nfs-client ..."
nfs_client node_list
echo "Installed nfs_client successfully"


echo " Installing nfs client provisioner in k8s cluster"
helm install stable/nfs-client-provisioner --name nfs --set nfs.server=$nfs_server_ip --set nfs.path=$nfsfolder
echo ".......... NFS Server configutaion with nfs-client provisioning is sucessfully completed in k8s-cluster......"
