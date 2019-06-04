#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan



claim="pv0001"
nfsserver_ip="10.170.0.28"
sudo mkdir -p /home/public/$claim
echo ".......... Changing ownership and permission to folder for nfs share ......"
sudo chown nobody:nogroup /home/public/$claim
sudo chmod 777 /home/public/$claim


#Fork the ov .yml file from Opsmx Github
curl https://raw.githubusercontent.com/OpsMx/k8s-kubespray/master/opsmx-k8s/opsmx-spinnaker/pv.yml -o pv.yml

Updating 
sed -i "s/pv_claim_name/$claim/g" pv.yml
sed -i "s/nfs_server_ip/$nfsserver_ip/g" pv.yml

printf "\n  [****] Displaying persisitance volume before pv creation [****] "
kubectl  get pv 

printf "\n  [****] Creating persisitance volume for the deployment [****] "
kubectl create -f k8s-kubespray/opsmx-k8s/opsmx-spinnaker/pv.yml

printf "\n  [****] Displaying persisitance volume after pv creation [****] "
kubectl  get pv 
