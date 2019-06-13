==================================================
Prometheus Deployment on Kubernetes Cluster
==================================================
1. Create a namespace with the below command:
	$ kubectl create namespace monitoring
	
2. Create a file named clusterRole.yml and create the role using the following command:	
	$ kubectl create -f clusterRole.yml
		clusterrole.rbac.authorization.k8s.io/prometheus created
		clusterrolebinding.rbac.authorization.k8s.io/prometheus created
	
3. Create a Config Map:
We should create a config map with all the prometheus scrape config and alerting rules, which will be mounted to the Prometheus container in /etc/prometheus as 'prometheus.yml' and 'prometheus.rules' files. The 'prometheus.yml' contains all the configuration to dynamically discover pods and services running in the kubernetes cluster. 'prometheus.rules' will contain all the alert rules for sending alerts to alert manager.
	
	i) Create a file called 'config-map.yml' and execute the following command to create the config map in kubernetes.
		$ kubectl create -f config-map.yml -n monitoring
			configmap/prometheus-server-conf created
		
		Related command for deleting the config-map:
		$ kubectl delete -f config-map.yml -n monitoring
		
4. Create a Prometheus Deployment:
	i) Create a file named 'prometheus-deployment.yml' and copy the following contents onto the file. In this configuration, we are mounting the Prometheus config map as a file inside '/etc/prometheus'. It uses the official Prometheus image from docker hub. 
		apiVersion: extensions/v1beta1
		kind: Deployment
		metadata:
		  name: prometheus-deployment
		  namespace: monitoring
		spec:
		  replicas: 1
		  template:
			metadata:
			  labels:
				app: prometheus-server
			spec:
			  containers:
				- name: prometheus
				  image: prom/prometheus:v2.1.0
				  args:
					- "--config.file=/etc/prometheus/prometheus.yml"
					- "--storage.tsdb.path=/prometheus/"
				  ports:
					- containerPort: 9090
				  volumeMounts:
					- name: prometheus-config-volume
					  mountPath: /etc/prometheus/
					- name: prometheus-storage-volume
					  mountPath: /prometheus/
			  volumes:
				- name: prometheus-config-volume
				  configMap:
					defaultMode: 420
					name: prometheus-server-conf
		  
				- name: prometheus-storage-volume
				  emptyDir: {}
	
	ii) Create a deployment on monitoring namespace.
		$ kubectl create -f prometheus-deployment.yml --namespace=monitoring
			deployment.extensions/prometheus-deployment created
		
		Related comands for verification:
		$ kubectl get deployments --namespace=monitoring
		$ kubectl get pod -n monitoring
		$ kubectl delete -f prometheus-deployment.yml --namespace=monitoring
		
		Related command for deleting deployment:
		$ kubectl delete -f prometheus-deployment.yml --namespace=monitoring
			deployment.extensions "prometheus-deployment" deleted
		
5. Exposing Prometheus as A Service:
	To access the Prometheus dashboard over a IP or a DNS name, you need to expose it as kubernetes service.
	i) Create a file named 'prometheus-service.yml' and copy the following contents. We will expose Prometheus on all kubernetes node IP’s on port 30000.
	
	apiVersion: v1
	kind: Service
	metadata:
	  name: prometheus-service
	spec:
	  selector: 
		app: prometheus-server
	  type: NodePort
	  ports:
		- port: 8080
		  targetPort: 9090 
		  nodePort: 30000
		  
	ii) Create the service using the following command:
		$ kubectl create -f prometheus-service.yml --namespace=monitoring
			service/prometheus-service created
			
		Related command for deleting deployment:
		$ kubectl delete -f prometheus-service.yml -n monitoring
			service "prometheus-service" deleted
	
	iii) Once created, you can access the Prometheus dashboard using any Kubernetes node IP on port 30000. If you are on the cloud, make sure you have the right firewall rules for accessing the apps.
	
============================================================================
node_exporter - v0.17.0
============================================================================
This produces metrics about infrastructure, including the current CPU, memory and disk usage, as well as I/O and network statistics, such as the number of bytes read from a disk or a server's average load.

1. Downloading Node Exporter on each target node.
	$ wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
Now, unpack the downloaded archive.	
	$ tar xvfz node_exporter-0.17.0.linux-amd64.tar.gz
Copy the binary to the /usr/local/bin directory and set the user and group ownership to the node_exporter user 
	$ sudo cp node_exporter-0.17.0.linux-amd64/node_exporter /usr/local/bin
	
2. Running Node Exporter as a service
	$ sudo vi /etc/systemd/system/node_exporter.service
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

Finally, reload systemd to use the newly created service.
	$ sudo systemctl daemon-reload
	
You can now run Node Exporter using the following command:
	$ sudo systemctl start node_exporter
	
Verify that Node Exporter's running correctly with the status command.
	$ sudo systemctl status node_exporter	
	This output tells you Node Exporter's status, main process identifier (PID), memory usage, and more.

Lastly, enable Node Exporter to start on boot.
	$ sudo systemctl enable node_exporter

Now all that’s left is to tell Prometheus server about the new target.
This needs to be done in the Prometheus config, as Node Exporter just exposes metrics and Prometheus pulls them from the targets it knows about.
Open your Prometheus config file prometheus.yml, and add your machine to the 'scrape_configs' section as follows:
	scrape_configs:
	  - job_name: 'node'
		static_configs:
		  - targets: ['<Private-IP>:9100']
