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

echo " .......Downloading minio templete file from OpsMx git repository wget..."
wget https://github.com/OpsMx/k8s-kubespray/blob/master/opsmx-k8s/opsmx-spinnaker/minio_templete.yml

echo " .......Downloading config file from OpsMx git repository using wget..."
wget https://github.com/OpsMx/k8s-kubespray/blob/master/opsmx-k8s/opsmx-spinnaker/config

echo " .......Downloading halyard templete file from OpsMx git repository using wget..."
wget https://github.com/OpsMx/k8s-kubespray/blob/master/opsmx-k8s/opsmx-spinnaker/halyard_templete.yml

echo " .......Downloading persistance volume file from OpsMx git repository using wget..."
wget https://github.com/OpsMx/k8s-kubespray/blob/master/opsmx-k8s/opsmx-spinnaker/pv.yml

echo "Deploying Minio ..."
echo "Enter the namespace"
read -p "  [****] Enter the Namespace where you want to Deploy Spinnaker and related services :" spinnaker_namespace

echo "Started Deploying minio in $spinnaker_namespace"
kubectl create namespace $spinnaker_namespace
status=$?
if test $status -eq 0
then
  echo "The namepsace '$spinnaker_namespace' is created successfully"
elif test $status -eq 1
then
  echo "The namespace '$spinnaker_namespace' is already exist!"
else
  echo "Failed to create the namepsace '$spinnaker_namespace'!"
  exit
fi

#### Create the Minio Deployment with service and ConfigMap.
echo "Updating minio config and halyard templete files" 
#Setting up the Minio Storage for the Deployment
printf "\n  [****] Setting up the Storage for the Spinnaker Deployment [****]" 
printf '\n'
read -p "  [****] Enter the Minio Access Key [Access key length should be between minimum 3 characters in length] :: " access_key
read -p "  [****] Enter the Minio Secret Access Key [Secret key should be in between 8 and 40 characters] :: " secret_access_key
printf '\n'

sed -i "s/MINIO-USER/$access_key/g" config
sed -i "s/MINIO-PASSWORD/$secret_access_key/g" config

printf '\n'

printf "\n   [****]  Fetching and Updating the Minio Secret [****] "
sed -i "s/SPINNAKER_NAMESPACE/$spinnaker_namespace/g" minio_templete.yml
sed -i "s/Minio-User/$access_key/g" minio_templete.yml
sed -i "s/Minio-Password/$secret_access_key/g" minio_templete.yml


echo "Started creating ConfigMap for minio in the namespace $spinnaker_namespace"
kubectl create -f minio_templete.yml -n $spinnaker_namespace  
status=$?
if test $status -eq 0
then
	echo "Created the minio deployment extension as minio-deployment successfully"
	echo "Created the minio service as minio-service successfully"
	echo "Created the minio ConfigMap as minio successfully"
else
	echo "Failed to create the minio deployment, service and ConfigMap!"
  #exit
fi
sleep 30
echo " Minio Pod status Checking"
kubectl get pod -n $spinnaker_namespace >> miniopod.txt
minio_pod=$(cat miniopod.txt | grep minio | awk '{print $1}')
minio_status=$(cat miniopod.txt | grep minio | awk '{print $3}')
echo "$minio_pod" 
echo "$minio_status" 
if [ "$minio_status" == Running ] ; then
	minio_ready=$(cat miniopod.txt | grep minio | awk '{print $2}')
	echo "$minio_ready" 
	minio_ready1=$(cat miniopod.txt | grep minio | awk '{print $2}' | cut -d "/" -f 2)
	echo "$minio_ready1" 
	minio_ready2=$(cat miniopod.txt | grep minio | awk '{print $2}' | cut -d "/" -f 1)
	echo "$minio_ready2" 
	if [ "$minio_ready1" = "$minio_ready2" ] ; then
	        echo "$minio_ready1" 
	        echo "$minio_ready2" 
			echo "$minio_ready" 
			echo "... Minio pod with pod name $minio_pod installed in the namespace "$spinnaker_namespace" "
	else
		echo "... Minio pod with pod name $minio_pod failed to install in the namespace "$spinnaker_namespace" "
	fi
else
	echo "... Minio pod with pod name $minio_pod failed to install in the namespace "$spinnaker_namespace" "
fi


# Create a configMap for the Kube config that would be mounted on the Halyard pod
echo "Started Create a configMap for the Kube config that would be mounted on the Halyard pod"
read -p  "Provide kube config file full path with kube config file (~/.kube/config):  " kube_path
kubectl create configmap kubeconfig --from-file=$kube_path -n $spinnaker_namespace
status=$?
if test $status -eq 0
then
  echo "Created the configmap as kubeconfig successfully" 
else
  echo "Failed to create the kubeconfig file!"
  #exit
fi


# Create a configMap for the Halyard config that would also be mounted on the Halyard Pod
echo " Updating config file"

read -p "  [****] Enter the Spinnaker version you like to deploy (1.13.5) :" spinnaker_version
sed -i "s/SPINNAKER-VERSION/$spinnaker_version/g" config

read -p "  [****] Enter the Docker user name (cisco11):" docker_username
sed -i "s/DOCKER-USERNAME/$docker_username/g" config
read -p "  [****] Enter the Docker user name (cisco@123):" docker_password
sed -i "s/DOCKER-PASSWORD/$docker_password/g" config
read -p "  [****] Enter the Docker repository name (cisco/restapp):" docker_repository
sed -i "s/DOCKER-REPOSITORY-NAME/$docker_repository/g" config
read -p "  [****] Enter the Jenkins name (jenkin-master):" jenkin_name
sed -i "s/JENKINS-NAME/$jenkin_name/g" config
read -p "  [****] Enter the Jenkins name (jenkin-master):" jenkin_username
sed -i "s/JENKINS-USER/$jenkin_username/g" config
read -p "  [****] Enter the Jenkins name (jenkin-master):" jenkin_password
sed -i "s/JENKINS-PASSWORD/$jenkin_password/g" config


sed -i "s/SPINNAKER_NAMESPACE/$spinnaker_namespace/g" config



echo "Started Configuring halyard config file "
kubectl create configmap halconfig --from-file=config -n $spinnaker_namespace
status=$?
if test $status -eq 0
then
  echo "Created the configmap as halconfig successfully" 
else
  echo "Failed to create the halconfig file!"
  #exit
fi


echo "Started Configuring halyard templete file "

sed -i "s/SPINNAKER_NAMESPACE/$spinnaker_namespace/g" halyard_templete.yml

kubectl create -f halyard_templete.yml -n $spinnaker_namespace
status=$?
if test $status -eq 0
then
  echo "Created spin halyard pod and service successfully"
else
  echo "Failed to create the service!"
  #exit
fi

echo " Checking deployment of pods in the created name space"
sleep 55
kubectl get pod -n $spinnaker_namespace >> spinpod.txt
echo " Wait untill the halyard pod is with Running status and 1/1 Ready"

spin_pod=$(cat spinpod.txt | grep spin-halyard | awk '{print $1}')
spin_status=$(cat spinpod.txt | grep spin-halyard | awk '{print $3}')
echo "$spin_pod" 
echo "$spin_status" 
if [ "$spin_status" == Running ] ; then
	spin_ready=$(cat spinpod.txt | grep spin-halyard | awk '{print $2}')
	echo "$spin_ready" 
	spin_ready1=$(cat spinpod.txt | grep spin-halyard | awk '{print $2}' | cut -d "/" -f 2)
	echo "$spin_ready1" 
	spin_ready2=$(cat spinpod.txt | grep spin-halyard | awk '{print $2}' | cut -d "/" -f 1)
	echo "$spin_ready2" 
	if [ "$spin_ready1" = "$spin_ready2" ] ; then
		echo "$spin_ready1" 
		echo "$spin_ready2" 
		echo "$spin_ready" 
		echo "... Spin halyard pod with pod name "$spin_pod" installed in the namespace "$spinnaker_namespace" "
	else
		echo "... Spin halyard pod with pod name "$spin_pod" failed to install in the namespace "$spinnaker_namespace" "
	fi
else
	echo "... Spin halyard pod with pod name "$spin_pod" failed to install in the namespace "$spinnaker_namespace" "
fi	








