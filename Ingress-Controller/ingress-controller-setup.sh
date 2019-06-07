#!/bin/bash
#### Organization : OpsMX
#### Author : Vijayendar Reddy D

if [ "${1}" = "h" ] || [ $# -lt 1 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
	echo "Usage: bash ingress-cotroller-setup.sh ingress.conf"
	exit 0
fi
clear

dos2unix "$1"
read_inputs()
{
  echo " ******** Started reading input values from $1..."
  file="$1"
  while IFS="=" read -r key value; do
    case "$key" in
      '#'*) ;;
      "NAME_SPACE") name_space="$value" ;;
      "SOURCE_PATH") src_space="$value" ;;
    esac
  done < "$file"
  echo " ******** Completed reading of input values from $1 ******** "
}

echo " ******* Started Setting-up the Ingress Controller ... ******** "

dos2unix "$1"
read_inputs $1

# Validating the inputs
if [ -z "$name_space" ]; then
        echo "Namespace is empty! Please specify the valid namespace in ingress.conf and try again!"
        exit 0
fi
if [ -z "$src_space" ]; then
        echo "SourcePath is empty! Please specify the valid valid path of the script location and try again!"
        exit 0
fi

echo " ******** Started updating of template yaml files ... ******** "
sed -e "s#@NAMESPACE@#${name_space}#g" $src_space/service-nodeport.yaml.temp > $src_space/service-nodeport.yaml
sed -e "s#@NAMESPACE@#${name_space}#g" $src_space/mandatory.yaml.temp > $src_space./mandatory.yaml
echo " ******** Completed the updating of template yaml files ******** "

echo " ******** Creating the ingress controller service ... ******** "
kubectl apply -f $src_space/service-nodeport.yaml
status=$?
if test $status -eq 0
then
  echo "Created the Ingress Controller Service successfully"
elif test $status -eq 1
then
  echo "The Ingress Controller Service is already exist!"
fi

# Create the 'nginx-ingress-controller' ingress controller deployment, along with the Kubernetes RBAC roles and bindings
echo " ******** Started creating the 'nginx-ingress-controller' ingress controller deployment, along with the Kubernetes RBAC roles and bindings"
kubectl apply -f $src_space/mandatory.yaml
status=$?
if test $status -eq 0
then
  echo " ******** Creating the nginx-ingress-controller ******** "
fi
echo " ********* Waiting for ingress nginx controller to be up and running ..."
sleep 30
echo ""
echo " ********* Disaplying ingress nginx controller details ..."
kubectl get all -n ingress-nginx

echo " ******** Completed settingup Ingress Controller successfully ******** "

echo " ******** Started creating the ingress rules for EFK, Prometheus, Graphana, Spinaker"
kubectl create -f $src_space/ingress-rules.yaml
status=$?
if test $status -eq 0
then
  echo " ******** Created the nginx-ingress-rules successfully ******** "
fi

