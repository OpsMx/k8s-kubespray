#!/bin/bash

echo "installing Prometheus locally ..."
namespace="monitoring"
prom_path="k8s-kubespray/kubespray-install/Prometheus/prometheus-setup/"

echo "Started installing Prometheus in $namespace"
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

# Create the role using the following command
kubectl create -f $prom_path/clusterRole.yml
status=$?
if test $status -eq 0
then
  echo "Created the CluterRole successfully"
elif test $status -eq 1
then
  echo "The ClusterRole is already exist!"
else
  echo "Failed to create the ClusterRole!"
fi

# Create a file called 'config-map.yml' and execute the following command to create the config map in kubernetes.
echo "Started creating ConfigMap in the name-space $namespace"
kubectl create -f $prom_path/config-map.yml -n $namespace
status=$?
if test $status -eq 0
then
  echo "Created the ConfigMap successfully"
else
  echo "Failed to create the ConfigMap!"
  #exit
fi

# Create a deployment on monitoring namespace.
echo "Started creating Deployment in the name-space $namespace"
kubectl create -f $prom_path/prometheus-deployment.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the deployment successfully"
else
  echo "Failed to create the deployment!"
  #exit
fi

# Create the service using the following command
echo "Started creating service in the name-space $namespace"
kubectl create -f $prom_path/prometheus-service.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the service successfully"
else
  echo "Failed to create the service!"
fi
echo "Installed Prometheus successfully"

echo "Started running node-exporter.yaml"
ansible-playbook -i $prom_path/k8s-host $prom_path/node-exporter.yaml
status=$?
if test $status -eq 0
then
  echo "Called node-exporter successfully"
fi

