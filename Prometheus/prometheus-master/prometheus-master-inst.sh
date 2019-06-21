#!/bin/bash

if [ "${1}" = "h" ] || [ $# -lt 1 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Usage: bash prometheus-master-inst.sh prometheus-master.ini"
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
      "SLAVE1_SOURCE") slave1src="$value" ;;
      "SLAVE1_PORT") slave1port="$value" ;;
    esac
  done < "$file"
  echo " ******** Completed reading of input values from $1 ******** "
}

echo " ********* Started installing Master Prometheus ********* "
dos2unix "$1"
read_inputs $1

# Create a user, and use the --no-create-home and --shell /bin/false options so that these users can't log into the server.
echo " ******* Creating 'prometheus' user ******** "
sudo useradd --no-create-home --shell /bin/false prometheus
# Create the necessary directories for storing Prometheus' files and data.
echo " ******* Creating the necessary directories for storing Prometheus files and data ********" 
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
# Set the user and group ownership on the new directories to the prometheus user.
echo " ******** Setting the user and group ownership on the new directories to the prometheus user *********"
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
# Download Prometheus v2.10.0
echo " ******** Downloading Prometheus, prometheus-2.10.0.linux-amd64.tar.gz ********"
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.10.0/prometheus-2.10.0.linux-amd64.tar.gz
tar xvf prometheus-2.10.0.linux-amd64.tar.gz
# Copy the two binaries to the /usr/local/bin directory.
echo " ******** Copying the binaries to /usr/local/bin/ *********"
sudo cp prometheus-2.10.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.10.0.linux-amd64/promtool /usr/local/bin/
# Set the user and group ownership on the binaries to the prometheus user.
echo " ******** Setting the user and group ownership on the binaries to the prometheus user ********"
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
# Copy the consoles and console_libraries directories to /etc/prometheus.
echo " ******** Copying the consoles and console_libraries directories to /etc/prometheus ********"
sudo cp -r prometheus-2.10.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.10.0.linux-amd64/console_libraries /etc/prometheus
# Set the user and group ownership on the directories to the prometheus user.
echo " ******* Setting the user and group ownership on the directories to the prometheus user ********"
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
echo " ******** Updating 'prometheus.yml' file with source and port details of Slave Promeheus ********"
sed -e "s#@SLAVE1SRC@#${slave1src}#g" -e "s#@SLAVE1PORT@#${slave1port}#g" ./prometheus.yml.temp > ./prometheus.yml
# Copy the prometheus.yml to /etc/prometheus/
echo " ******** Copying the updated prometheus.yml to /etc/prometheus/ ********"
sudo cp ./prometheus.yml /etc/prometheus/
# The prometheus.service file tells systemd to run Prometheus as the prometheus user, with the configuration file located in the /etc/prometheus/prometheus.yml directory and to store its data in the /var/lib/prometheus directory.
echo " ********* Copying 'prometheus.service' to /etc/systemd/system/ *********"
sudo cp ./prometheus.service /etc/systemd/system/
# To use the newly created service, reload systemd.
sudo systemctl daemon-reload
status=$?
if test $status -eq 0
then
  echo " ********* Reloaded systemd init system successfully *********"
fi
# Start Prometheus as a service
sudo systemctl start prometheus
status=$?
if test $status -eq 0
then
  echo " ******** Started Master Prometheus Service successfully ******** "
fi
# Enable the service to start on boot.
sudo systemctl enable prometheus

