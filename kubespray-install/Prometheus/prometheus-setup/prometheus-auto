#!/bin/bash
minion_list=("x.x.x.x" "x.x.x.x" "x.x.x.x" "x.x.x.x")
user_names=("username" "username" "username" "username")

# This is required to be executed for each minion node.
function install_nodeexporter() {
  local -n nodelist=$1
  local -n userlist=$2
  #printf '1: %q\n' "${nodelist[@]}"
  #printf '2: %q\n' "${userlist[@]}"
  for ((i=0;i<${#nodelist[@]};++i))
  do
    echo ""
    echo "************* Connecting to ${nodelist[i]} with ${userlist[i]} *************"
    # Download Node Exporter on each target node
    echo "Started installing wget..."
    ssh ${userlist[i]}@${nodelist[i]} "sudo apt-get install wget -y"
    # Downloading Node Exporter on each target node
    echo "Started Dowloading node_exporter ..."
    ssh ${userlist[i]}@${nodelist[i]} "wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz"
    # unpack the downloaded archive
    echo "Started unarchiving node_exporter binary ..."
    ssh ${userlist[i]}@${nodelist[i]} "tar xvfz node_exporter-0.17.0.linux-amd64.tar.gz"
     # Copy the binary to the /usr/local/bin directory
    echo "Started copying node_exporter to /usr/local/bin location ..."
    ssh ${userlist[i]}@${nodelist[i]} "sudo cp node_exporter-0.17.0.linux-amd64/node_exporter /usr/local/bin"

    # Running Node Exporter as a service
    # sudo vi /etc/systemd/system/node_exporter.service
    echo "Updating node_exporter.service file for running node_exporter as a service ..."
    echo "Connecting ${nodelist[i]} with ${user_names[i]}"
    ssh ${user_names[i]}@${nodelist[i]} "sudo tee /etc/systemd/system/node_exporter.service" > /dev/null <<EOF
    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network-online.target
    [Service]
    User=root
    Group=root
    Type=simple
    ExecStart=/usr/local/bin/node_exporter
    [Install]
    WantedBy=multi-user.target
EOF
    # reload systemd to use the newly created service.
    echo "Reloading newly created service ..."
    ssh ${userlist[i]}@${nodelist[i]} "sudo systemctl daemon-reload"
    # run Node Exporter using the following command:
    echo "Starting node_exporter service ..."
    ssh ${userlist[i]}@${nodelist[i]} "sudo systemctl start node_exporter"
  done
}

echo "installing Prometheus locally ..."
echo "Enter the namespace"
read -r namespace

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
kubectl create -f clusterRole.yml
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
kubectl create -f config-map.yml -n $namespace
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
kubectl create -f prometheus-deployment.yml --namespace=$namespace
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
kubectl create -f prometheus-service.yml --namespace=$namespace
status=$?
if test $status -eq 0
then
  echo "Created the service successfully"
else
  echo "Failed to create the service!"
  #exit
fi
echo "Installed Prometheus successfully"

echo "Started installing node_exporter on each minion node ..."
install_nodeexporter minion_list user_names
echo "Installed node_exporter successfully"
