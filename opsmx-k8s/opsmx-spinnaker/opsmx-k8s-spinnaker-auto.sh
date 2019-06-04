#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan


#### First verify kubectl binary is available in the system to deploy spinnaker in k8s-cluster.

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

### Download required templates for configuration

printf "\n  [****] Starting the Distributed Spinnaker Lite Version Installation [****] "
printf '\n'
printf "\n  [****] Spinnaker would be installed in the Spinnaker Namespace which it would create by default [****] "
printf '\n'
printf "\n  [****] Please ensure you have a docker login for pushing the script to customized repository [****] "


spinnaker_namespace="spinnaker"
access_key="minio"
secret_access_key="minio1234"
# kube_path="~/.kube/config"


printf "\n"

kubectl create namespace $spinnaker_namespace

printf "\n  [****] Displaying all the runing pods in specified namespace [****] "
kubectl -n $spinnaker_namespace  get pods 

printf "\n  [****] Displaying all the Availabe persisitance volume [****] "
kubectl  get pv 

#Setting up the Minio Storage for Spinnaker Deployment
printf "\n  [****] Setting up the Storage for the Spinnaker Deployment [****]" 
printf '\n'

printf '\n'
base1=$(echo -ne "$access_key" |base64)
base2=$(echo -ne "$secret_access_key" |base64)

printf "\n   [****]  Fetching and Updating the Minio Secret [****] "
printf '\n'
curl https://raw.githubusercontent.com/OpsMx/k8s-kubespray/master/opsmx-k8s/opsmx-spinnaker/minio_templete.yml -o minio_template.yml
printf '\n'
sed -i "s/base64convertedaccesskey/$base1/" minio_template.yml
sed -i "s/base64convertedSecretAccesskey/$base2/" minio_template.yml
sed -i "s/SPINNAKER_NAMESPACE/$spinnaker_namespace/g" minio_template.yml

printf "\n  [****] Displaying persisitance volume before minio claim [****] "
kubectl  get pv 
printf "\n  [****] Creating minio pod [****] "
kubectl create -n $spinnaker_namespace -f minio_template.yml
sleep 10


printf "\n  [****] Displaying persisitance volume after minio claim [****] "
kubectl  get pv 

printf "\n  [****] Displaying all the runing pods in specified namespace [****] "
kubectl -n $spinnaker_namespace  get pods 

#Fork the files from Opsmx Github
printf "\n  [****] Fetching the files for the Halyard Template and the ConfigMap for the deployment  [****]" 
printf '\n'
curl https://raw.githubusercontent.com/OpsMx/k8s-kubespray/master/opsmx-k8s/opsmx-spinnaker/spinhalyardconfig_templete.yml -o halconfigmap_template.yml
printf '\n' 
curl https://raw.githubusercontent.com/OpsMx/k8s-kubespray/master/opsmx-k8s/opsmx-spinnaker/halyard_templete.yml -o halyard_template.yml
printf '\n'



#changing the values in halyard-template and halconfig

sed -i "s/SPINNAKER_NAMESPACE/$spinnaker_namespace/g" halyard_template.yml
sed -i "s/SPINNAKER_NAMESPACE/$spinnaker_namespace/g" halconfigmap_template.yml

#Applying the Halyard Pod
printf "\n  [****] Configuring the Dependencies [****]"
printf '\n'


#Updating the configs in the  Environment 

printf " \n  [****] Updating configmap [****]" 


sed -i "s/MINIO_USER/$access_key/" halconfigmap_template.yml
sed -i "s/MINIO_PASSWORD/$secret_access_key/" halconfigmap_template.yml


printf "\n  [****] Applying The Halyard ConfigMap, Secrets and the Halyard Deployment Pod [****] "

printf '\n'

printf "\n  [****] Creating  halconfig from halconfigmap template file [****] "
kubectl apply -f halconfigmap_template.yml -n $spinnaker_namespace

printf "\n  [****] Creating secret for kubeconfig from kubeconnfig file [****] "
kubectl create secret generic kubeconfig --from-file=$kube_path -n $spinnaker_namespace

## Deploying spin-halyard pod to initiate hal deply apply
printf "\n  [****] Creating spin-halyard pod [****] "
kubectl apply -f halyard_template.yml -n $spinnaker_namespace
sleep 35
printf "\n  [****] Displaying all the runing pods in specified namespace [****] "
kubectl -n $spinnaker_namespace  get pods 
printf '\n'
printf "\n  [****] Storing spin-halyard pod in a spin_pod to use further in the script [****] "
spin_pod=`kubectl -n $spinnaker_namespace  get pods | grep spin-halyard | awk '{print $1}'`



