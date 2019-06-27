#!./bin./bash
#### Organization : OpsMX
#### Author : Vijayendar Reddy D
if [ "${1}" = "h" ] || [ $# -lt 1 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Usage: bash prometheus-auto.sh prometheus.ini"
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
      "NAME_SPACE") namespace="$value" ;;
      "SOURCE_COMPLETEPATH") prom_path="$value" ;;
    esac
  done < "$file"
  echo " ******** Completed reading of input values from $1 ******** "
}

dos2unix "$1"
read_inputs $1

# Validating the inputs
if [ -z "$namespace" ]; then
  echo "The namespace is empty! Please specify the valid namespace name for Prometheus and try again!"
  exit 0
fi

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

echo " ******** Updating 'clusterRole.yml' file with with the given namespace ********"
sed -e "s#@NAMESPACE@#${namespace}#g" ./clusterRole.yml.temp > ./clusterRole.yml
sleep 5

# Create the role using the following command
kubectl create -f "$prom_path"/clusterRole.yml
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

echo " ******** Updating 'config-map.yml' file with with the given namespace ********"
sed -e "s#@NAMESPACE@#${namespace}#g" ./config-map.yml.temp > ./config-map.yml
sleep 5

# Create a file called 'config-map.yml' and execute the following command to create the config map in kubernetes.
echo "Started creating ConfigMap in the name-space $namespace"
kubectl create -f "$prom_path"/config-map.yml -n $namespace
status=$?
if test $status -eq 0
then
  echo "Created the ConfigMap successfully"
else
  echo "Failed to create the ConfigMap!"
fi

echo " ******** Updating 'prometheus-deployment.yml' file with with the given namespace ********"
sed -e "s#@NAMESPACE@#${namespace}#g" ./prometheus-deployment.yml.temp > ./prometheus-deployment.yml
sleep 5
# Create a deployment on monitoring namespace.
echo "Started creating Deployment in the name-space $namespace"
kubectl create -f "$prom_path"/prometheus-deployment.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the deployment successfully"
else
  echo "Failed to create the deployment!"
fi

# Create the service using the following command
echo "Started creating service in the name-space $namespace"
kubectl create -f "$prom_path"/prometheus-service.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the service successfully"
else
  echo "Failed to create the service!"
fi
echo "Installed Prometheus successfully"

echo "Started running node-exporter.yaml"
ansible-playbook -i "$prom_path"/k8s-host "$prom_path"/node-exporter.yaml
status=$?
if test $status -eq 0
then
  echo "Called node-exporter successfully"
fi

