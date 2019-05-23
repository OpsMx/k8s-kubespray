#!/bin/bash
echo "installing EFK in Kubernetes cluster ..."
echo "Enter the namespace"
read -r namespace

echo "Started installing EFK in $namespace"
kubectl create namespace $namespace
status=$?
if test $status -eq 0
then
  echo "The namepsace '$namespace' is created successfully"
elif test $status -eq 1
then
  echo "The namespace '$namespace' is already exist!"
else
  echo "Failed to create the namepsace '$namespace'!"
  exit
fi

echo "Installing helm in the launch machine"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
status=$?
if test $status -eq 0
then
  echo "The helm is installed successfully"
elif test $status -eq 1
then
  echo "'helm' is already exist!"
else
  echo "Failed to install helm!"
  exit
fi

echo "Create a service account and then bind the cluster-admin role to the service account"
kubectl create serviceaccount tiller --namespace $namespace
status=$?
if test $status -eq 0
then
  echo "Created service account successfully in $namespace namespace"
elif test $status -eq 1
then
  echo "'service account' is already exist in $namespace namespace!"
else
  echo "Failed to create service account in $namespace namespace!"
  exit
fi

echo "Binding the cluster-admin role to the service account"
kubectl create clusterrolebinding tiller-deploy --clusterrole cluster-admin --serviceaccount $namespace:tiller
status=$?
if test $status -eq 0
then
  echo "Created the CluterRoleBinding successfully in $namespace namespace for admin"
elif test $status -eq 1
then
  echo "The Cluster Admin Role is already exist in $namespace namespace for admin!"
else
  echo "Failed to create the ClusterRole in $namespace namespace for admin!"
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

echo "Installing elastic search operator helm chart"
helm repo add es-operator https://raw.githubusercontent.com/upmc-enterprises/elasticsearch-operator/master/charts/
status=$?
if test $status -eq 0
then
  echo "Added elastic search operator helm chart successfully"
else
  echo "Failed to add elastic search operator helm chart!"
fi

helm install --set rbac.enabled=true --name es-operator --namespace $namespace es-operator/elasticsearch-operator
status=$?
if test $status -eq 0
then
  echo "Installed elastic search operator helm chart successfully in $namespace namespace"
else
  echo "Failed to install elastic search operator helm chart in $namespace namespace!"
fi

echo "Getting the custom helm umbrella chart for the EFK configuration"
wget https://github.com/OpsMx/k8s-kubespray/blob/master/efk-0.0.1.tgz
status=$?
if test $status -eq 0
then
  echo "Downloaded the custom helm umbrella chart successfully"
else
  echo "Failed to download the custom helm umbrella chart!"
fi

echo "Started installing the custom helm umbrella chart ..."
helm install --name efk --namespace $namespace efk-0.0.1.tgz
status=$?
if test $status -eq 0
then
  echo "Installed the custom helm umbrella chart successfully in $namespace namespace"
else
  echo "Failed to install the custom helm umbrella chart in $namespace namespace!"
fi

echo "Forwarding efk-kibana service to local host ..."
kubectl port-forward efk-kibana 5601 -n $namespace
status=$?
if test $status -eq 0
then
  echo "Forwarded efk-kibana service to local host successfully in $namespace namespace"
else
  echo "Failed to forward efk-kibana service to local host!"
fi
