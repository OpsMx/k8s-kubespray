#!/bin/bash

#### Organization : OpsMX
#### Author : M Gnana Seelan

#!/bin/bash
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
if test $status -eq 0
then
  echo "Installed tiller successfully"
elif test $status -eq 1
then
  echo "The tiller installation is already exist!"
else
  echo "Failed to install tiller!"
fi

	
	
	
	
	








