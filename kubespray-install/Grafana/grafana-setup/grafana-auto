#!/bin/bash
echo "installing Grafana locally ..."
echo "Enter the namespace"
read -r namespace

echo "Started installing Grafana in $namespace"
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

# Create a deployment on monitoring namespace.
echo "Started creating Deployment in the name-space $namespace"
kubectl create -f grafana-deployment.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the Grafana deployment successfully"
else
  echo "Failed to create the Grafana deployment!"
  #exit
fi

# Create the service using the following command
echo "Started creating service in the name-space $namespace"
kubectl create -f grafana-service.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the service successfully"
else
  echo "Failed to create the service!"
  #exit
fi
echo "Installed Grafana successfully"
