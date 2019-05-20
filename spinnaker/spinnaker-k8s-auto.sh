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
wget https://github.com/OpsMx/k8s-kubespray/blob/master/spinnaker/minio_template.yml

echo " .......Downloading config file from OpsMx git repository using wget..."
wget https://github.com/OpsMx/k8s-kubespray/blob/master/spinnaker/config

echo " .......Downloading halyard templete file from OpsMx git repository using wget..."
wget https://github.com/OpsMx/k8s-kubespray/blob/master/spinnaker/halyard_template.yml


echo "Deploying Minio ..."
echo "Enter the namespace"
read -r namespace
read -r MINIO_ACCESS_KEY
read -r MINIO_SECRET_KEY



echo "Started Deploying minio in $namespace"
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

echo " .. Configuring Minio_templete.yml as per the requirement.."
echo " Updating namespace in the minio_templete.yml ........."
sed -i "s/namespace/$namespace/g" minio_template.yml
echo " Updating user name in the minio_templete.yml ........."
sed -i "s/MINIO_ACCESS_KEY/$MINIO_ACCESS_KEY/" minio_template.yml
echo " Updating password in the minio_templete.yml ........."
sed -i "s/MINIO_SECRET_KEY/$MINIO_SECRET_ACCESS_KEY/" minio_template.yml  

#### Create the Minio Deployment with service and ConfigMap.
echo "Started creating ConfigMap for minio in the name-space $namespace"
kubectl create -f minio_template.yml -n $namespace  
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

echo " Minio Pod status Checking"

minio_pod=$(kubectl get pods -n "$namespace" | grep minio | awk '{print $1}')
minio_status=$(kubectl get pods -n "$namespace" | grep minio | awk '{print $3}')
echo "$minio_pod" 
echo "$minio_status" 
if [ "$minio_status" == Running ] ; then
	minio_ready=$(kubectl get pods -n "$namespace" | grep minio | awk '{print $2}')
	echo "$minio_ready" 
	minio_ready1=$(kubectl get pods -n "$namespace" | grep minio | awk '{print $2}' | cut -d "/" -f 2)
	echo "$minio_ready1" 
	minio_ready2=$(kubectl get pods -n "$namespace" | grep minio | awk '{print $2}' | cut -d "/" -f 1)
	echo "$minio_ready2" 
	if [ "$minio_ready1" = "$minio_ready2" ] ; then
	        echo "$minio_ready1" 
	        echo "$minio_ready2" 
			echo "$minio_ready" 



# Create a configMap for the Kube config that would be mounted on the Halyard pod
echo "Started Create a configMap for the Kube config that would be mounted on the Halyard pod"
echo "Provide kube config file full path with kube config file "
read -r kube_path
kubectl create configmap kubeconfig --from-file=$kube_path -n namespace
status=$?
if test $status -eq 0
then
  echo "Created the configmap as kubeconfig successfully" 
else
  echo "Failed to create the kubeconfig file!"
  #exit
fi

# Create a configMap for the Halyard config that would also be mounted on the Halyard Pod
echo "Started Configuring halyard config file "

4. Create a configMap for the Halyard config that would also be mounted on the Halyard Pod
        Please make sure you make to substitute the corresponding values where it has been commented on the config file that you have forked. Once done please proceed to create the configMap :
    $ kubectl create configmap halconfig --from-file=config -n namespace
  	$ kubectl create configmap halconfig --from-file=config -n dvrns
		configmap/halconfig created




echo "Started Configuring halyard templete file "
echo " Updating namespace in the minio_templete.yml ........."
sed -i "s/namespace/$namespace/g" halyard_template.yml

kubectl create -f halyard_template.yml -n $namespace
status=$?
if test $status -eq 0
then
  echo "Created spin halyard pod and service successfully"
else
  echo "Failed to create the service!"
  #exit
fi

echo " Checking deployment of pods in the created name space"
kubectl get pod -n $namespace
echo " Wait untill the halyard pod is with Running status and 1/1 Ready"
spin_pod=$(kubectl get pods -n "$namespace" | grep spin-halyard | awk '{print $1}')
		spin_status=$(kubectl get pods -n "$namespace" | grep spin-halyard | awk '{print $3}')
		echo "$spin_pod" 
		echo "$spin_status" 
		if [ "$spin_status" == Running ] ; then
			spin_ready=$(kubectl get pods -n "$namespace" | grep spin-halyard | awk '{print $2}')
			echo "$spin_ready" 
			spin_ready1=$(kubectl get pods -n "$namespace" | grep spin-halyard | awk '{print $2}' | cut -d "/" -f 2)
			echo "$spin_ready1" 
			spin_ready2=$(kubectl get pods -n "$namespace" | grep spin-halyard | awk '{print $2}' | cut -d "/" -f 1)
			echo "$spin_ready2" 
			if [ "$spin_ready1" = "$spin_ready2" ] ; then
			        echo "$spin_ready1" 
			        echo "$spin_ready2" 
					echo "$spin_ready" 
					



echo " Once halyard pod is ready the enter into the pod for deployment"
kubectl exec -it podname /bin/bash -n $namespace
	
sp_status=Running
sp_ready=1
spinnaker_ver_stat=0

current_status=$(kubectlget pods -n "$namespace" | grep spin-halyard | awk '{print $3}')
if [ "$current_status" == Running ]; then
	halyard_podname=$(kubectlget pods -n "$namespace" | grep spin-halyard | awk '{print $1}')
	echo "$halyard_podname" 
	## Spinnaker deployment version configuration in the spin-halyard pod
	kubectl-n "$namespace" rsh "$halyard_podname" /bin/bash hal config version edit --version 1.13.6 
	sleep 10

	if [ $? -eq "$spinnaker_ver_stat" ]; then 
		## hal deploy apply after the spinnaker deployment version configuration
		kubectl-n "$namespace" rsh "$halyard_podname" /bin/bash hal deploy apply 
		sleep 110
		### Hal Deploy Apply First Cycle pod Running and Steady Status checking starts
		### The Pod details	
		deck_pod=$(kubectlget pods -n "$namespace" | grep deck | awk '{print $1}')
		redis_pod=$(kubectlget pods -n "$namespace" | grep redis | awk '{print $1}')
		gate_pod=$(kubectlget pods -n "$namespace" | grep gate | awk '{print $1}')
		rosco_pod=$(kubectlget pods -n "$namespace" | grep rosco | awk '{print $1}')
		echo_pod=$(kubectlget pods -n "$namespace" | grep echo | awk '{print $1}')		
		orca_pod=$(kubectlget pods -n "$namespace" | grep orca | awk '{print $1}')
		clouddriver_pod=$(kubectlget pods -n "$namespace" | grep clouddriver | awk '{print $1}')
		front50_pod=$(kubectlget pods -n "$namespace" | grep front50 | awk '{print $1}')
		fiat_pod=$(kubectlget pods -n "$namespace" | grep fiat | awk '{print $1}')
	
		### The Pods Running Status
		deck_status=$(kubectlget pods -n "$namespace" | grep deck | awk '{print $3}')	
		redis_status=$(kubectlget pods -n "$namespace" | grep redis | awk '{print $3}')	
		gate_status=$(kubectlget pods -n "$namespace" | grep gate | awk '{print $3}')
		rosco_status=$(kubectlget pods -n "$namespace" | grep rosco | awk '{print $3}')
		echo_status=$(kubectlget pods -n "$namespace" | grep echo | awk '{print $3}')
		orca_status=$(kubectlget pods -n "$namespace" | grep orca | awk '{print $3}')
		clouddriver_status=$(kubectlget pods -n "$namespace" | grep clouddriver | awk '{print $3}')
		front50_status=$(kubectlget pods -n "$namespace" | grep front50 | awk '{print $3}')
		fiat_status=$(kubectlget pods -n "$namespace" | grep fiat | awk '{print $3}')

		### The Pods Ready Status
		deck_ready=$(kubectlget pods -n "$namespace" | grep deck | awk '{print $2}' | cut -d "/" -f 1)
		redis_ready=$(kubectlget pods -n "$namespace" | grep redis | awk '{print $2}' | cut -d "/" -f 1)
		gate_ready=$(kubectlget pods -n "$namespace" | grep gate | awk '{print $2}' | cut -d "/" -f 1)
		rosco_ready=$(kubectlget pods -n "$namespace" | grep rosco | awk '{print $2}' | cut -d "/" -f 1)
		echo_ready=$(kubectlget pods -n "$namespace" | grep echo | awk '{print $2}' | cut -d "/" -f 1)
		orca_ready=$(kubectlget pods -n "$namespace" | grep orca | awk '{print $2}' | cut -d "/" -f 1)
		clouddriver_ready=$(kubectlget pods -n "$namespace" | grep clouddriver | awk '{print $2}' | cut -d "/" -f 1)
		front50_ready=$(kubectlget pods -n "$namespace" | grep front50 | awk '{print $2}' | cut -d "/" -f 1)
		fiat_ready=$(kubectlget pods -n "$namespace" | grep fiat | awk '{print $2}' | cut -d "/" -f 1)


		if [ "$deck_status" == "$sp_status" ] && [ "$redis_status" == "$sp_status" ] && [ "$gate_status" == "$sp_status" ] && [  "$rosco_status" == "$sp_status" ] && [  "$echo_status" == "$sp_status" ] && [  "$orca_status" == "$sp_status" ] && [  "$clouddriver_status" == "$sp_status" ] && [ "$front50_status" == "$sp_status" ] && [  "$fiat_status" == "$sp_status" ] ; then 
			sp_pod1=("$deck_pod" "$redis_pod" "$gate_pod" "$rosco_pod" "$echo_pod" "$orca_pod" "$clouddriver_pod" "$front50_pod" "$fiat_pod")
			len_sp_pod1=${#sp_pod1[@]}
			echo "$len_sp_pod1" 
			for (( i=0; i<len_sp_pod1; i++ ));
			do
				echo "${sp_pod1[$i]}"  
			done
			sleep 5
			# kubectlget pods -n "$namespace"
			# echo " All Pods up Ruuning state  in First attempt"
			sp_status1=("$deck_status" "$redis_status" "$gate_status" "$rosco_status" "$echo_status" "$orca_status" "$clouddriver_status" "$front50_status" "$fiat_status")
			len_sp_status1=${#sp_status1[@]}
			echo "$len_sp_status1" 
			for (( j=0; j<len_sp_status1; j++ ));
			do
				echo "${sp_status1[$j]}" 
			done
			sleep 5
			if [ "$deck_ready" == "$sp_ready" ] && [  "$redis_ready" == "$sp_ready" ] && [  "$gate_ready" == "$sp_ready" ] && [  "$rosco_ready" == "$sp_ready" ] && [  "$echo_ready" == "$sp_ready" ] && [  "$orca_ready" == "$sp_ready" ] && [  "$clouddriver_ready" == "$sp_ready"  ] && [  "$front50_ready" == "$sp_ready" ] && [  "$fiat_ready" == "$sp_ready" ] ; then
				sp_ready1=("$deck_ready" "$redis_ready" "$gate_ready" "$rosco_ready" "$echo_ready" "$orca_ready" "$clouddriver_ready" "$front50_ready" "$fiat_ready")
				len_sp_ready1=${#sp_ready1[@]}
				echo "$len_sp_ready1" 
				for (( k=0; k<len_sp_ready1; k++ ));
				do
					echo "${sp_ready1[$k]}" 
				done
				# echo " All Pods up running and ready state  in First attempt"
				# kubectlget pods -n "$namespace"
				sleep 10
				## Changing ClusterIP to NodePort for Deck and Gate
				kubectlpatch svc spin-deck --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n "$namespace" 
				sleep 3
				kubectlpatch svc spin-gate --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n "$namespace" 
				sleep 3
				# kubectlget svc -n "$namespace"
				echo $spinnaker_dep_stat 
				## Getting the IP of Spinnaker URL 
				ip_address="$(curl -s http://checkip.amazonaws.com)" 
				sleep 2
				## Getting the port of Spinnaker URL service
				deck_Port=`kubectlget svc -n "$namespace" | grep spin-deck | awk '{print $5}' | cut -d ":" -f 2 | cut -d "/" -f 1`
				gate_Port=`kubectlget svc -n "$namespace" | grep spin-gate | awk '{print $5}' | cut -d ":" -f 2 | cut -d "/" -f 1`
				echo $gate_Port 
				echo $deck_Port 
				sleep 5
				echo "{ \"status\" : \"success\", \"message\" :\"Successfully deployed spinnaker version: $SPT_SPIN_DIPLOYMENT_VERSION in namespace: $SPT_SPINNAKER_NAMESPACE with the ip address:\", \"ipaddress\" : \"""$ip_address""\",\"port\":\"$deck_Port\" }"
				exit 1;			
					
			else
				# echo " First Cycle failed "				
				kubectldelete pod "$fiat_pod" -n "$namespace" 
				kubectldelete pod "$gate_pod" -n "$namespace" 
				sleep 75
				deck_pod=$(kubectlget pods -n "$namespace" | grep deck | awk '{print $1}')
				redis_pod=$(kubectlget pods -n "$namespace" | grep redis | awk '{print $1}')
				rosco_pod=$(kubectlget pods -n "$namespace" | grep rosco | awk '{print $1}')
				echo_pod=$(kubectlget pods -n "$namespace" | grep echo | awk '{print $1}')		
				orca_pod=$(kubectlget pods -n "$namespace" | grep orca | awk '{print $1}')
				clouddriver_pod=$(kubectlget pods -n "$namespace" | grep clouddriver | awk '{print $1}')
				front50_pod=$(kubectlget pods -n "$namespace" | grep front50 | awk '{print $1}')
				## Recreated as not Ready in first round of check     
				gate_pod=$(kubectlget pods -n "$namespace" | grep gate | awk '{print $1}')
				fiat_pod=$(kubectlget pods -n "$namespace" | grep fiat | awk '{print $1}')
				## Status check
				deck_status=$(kubectlget pods -n "$namespace" | grep deck | awk '{print $3}')	
				redis_status=$(kubectlget pods -n "$namespace" | grep redis | awk '{print $3}')	
				rosco_status=$(kubectlget pods -n "$namespace" | grep rosco | awk '{print $3}')
				echo_status=$(kubectlget pods -n "$namespace" | grep echo | awk '{print $3}')
				orca_status=$(kubectlget pods -n "$namespace" | grep orca | awk '{print $3}')
				clouddriver_status=$(kubectlget pods -n "$namespace" | grep clouddriver | awk '{print $3}')
				front50_status=$(kubectlget pods -n "$namespace" | grep front50 | awk '{print $3}')
				## Recreated as not Ready in first round of check
				gate_status=$(kubectlget pods -n "$namespace" | grep gate | awk '{print $3}')
				fiat_status=$(kubectlget pods -n "$namespace" | grep fiat | awk '{print $3}')
				
				if [ "$deck_status" == "$sp_status" ] && [ "$redis_status" == "$sp_status" ] && [ "$gate_status" == "$sp_status" ] && [  "$rosco_status" == "$sp_status" ] && [  "$echo_status" == "$sp_status" ] && [  "$orca_status" == "$sp_status" ] && [  "$clouddriver_status" == "$sp_status" ] && [ "$front50_status" == "$sp_status" ] && [  "$fiat_status" == "$sp_status" ] ; then 
					sp_pod2=("$deck_pod" "$redis_pod" "$gate_pod" "$rosco_pod" "$echo_pod" "$orca_pod" "$clouddriver_pod" "$front50_pod" "$fiat_pod")
					len_sp_pod2=${#sp_pod2[@]}
					echo "$len_sp_pod2" 
					for (( l=0; l<len_sp_pod2; l++ ));
					do
						echo "${sp_pod2[$l]}" 
					done
					Sleep 5
					sp_status2=("$deck_status" "$redis_status" "$gate_status" "$rosco_status" "$echo_status" "$orca_status" "$clouddriver_status" "$front50_status" "$fiat_status")
					len_sp_status2=${#sp_status1[@]}
					echo "$len_sp_status2" 
					for (( m=0; m<len_sp_status2; m++ ));
					do
						echo "${sp_status2[$m]}" 
					done
					Sleep 5
					# kubectlget pods -n "$namespace"
					# echo " All Pods up Ruuning state  in Second attempt"
					## Ready check
					deck_ready=$(kubectlget pods -n "$namespace" | grep deck | awk '{print $2}' | cut -d "/" -f 1)
					redis_ready=$(kubectlget pods -n "$namespace" | grep redis | awk '{print $2}' | cut -d "/" -f 1)
					rosco_ready=$(kubectlget pods -n "$namespace" | grep rosco | awk '{print $2}' | cut -d "/" -f 1)
					echo_ready=$(kubectlget pods -n "$namespace" | grep echo | awk '{print $2}' | cut -d "/" -f 1)
					orca_ready=$(kubectlget pods -n "$namespace" | grep orca | awk '{print $2}' | cut -d "/" -f 1)
					clouddriver_ready=$(kubectlget pods -n "$namespace" | grep clouddriver | awk '{print $2}' | cut -d "/" -f 1)
					front50_ready=$(kubectlget pods -n "$namespace" | grep front50 | awk '{print $2}' | cut -d "/" -f 1)
					## Recreated as not Ready in first round of check
					gate_ready=$(kubectlget pods -n "$namespace" | grep gate | awk '{print $2}' | cut -d "/" -f 1)
					fiat_ready=$(kubectlget pods -n "$namespace" | grep fiat | awk '{print $2}' | cut -d "/" -f 1)
					
					if [ "$deck_ready" == "$sp_ready" ] && [  "$redis_ready" == "$sp_ready" ] && [  "$gate_ready" == "$sp_ready" ] && [  "$rosco_ready" == "$sp_ready" ] && [  "$echo_ready" == "$sp_ready" ] && [  "$orca_ready" == "$sp_ready" ] && [  "$clouddriver_ready" == "$sp_ready"  ] && [  "$front50_ready" == "$sp_ready" ] && [  "$fiat_ready" == "$sp_ready" ] ; then
						sp_ready2=("$deck_ready" "$redis_ready" "$gate_ready" "$rosco_ready" "$echo_ready" "$orca_ready" "$clouddriver_ready" "$front50_ready" "$fiat_ready")
						len_sp_ready2=${#sp_ready2[@]}
						echo "$len_sp_ready2" 
						for (( n=0; n<len_sp_ready2; n++ ));
						do
							echo "${sp_ready2[$n]}" 
						done
						# kubectlget pods -n "$namespace"
						# kubectlget svc -n "$namespace"
						# echo " All Pods up running and ready state in second attempt "
						sleep 10
						## Changing ClusterIP to NodePort for Deck and Gate
						kubectlpatch svc spin-deck --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n "$namespace" 
						sleep 5
						kubectlpatch svc spin-gate --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n "$namespace" 
						sleep 5 
						# kubectlget svc -n "$namespace"
						## Getting the IP of Spinnaker URL 
						ip_address="$(curl -s http://checkip.amazonaws.com)" 
						sleep 2
						## Getting the port of Spinnaker URL service
						deck_Port=`kubectlget svc -n "$namespace" | grep spin-deck | awk '{print $5}' | cut -d ":" -f 2 | cut -d "/" -f 1`
						sleep 5
						gate_Port=`kubectlget svc -n "$namespace" | grep spin-gate | awk '{print $5}' | cut -d ":" -f 2 | cut -d "/" -f 1`
						sleep 5
						echo $gate_Port 
						echo $deck_Port 
						echo "{ \"status\" : \"success\", \"message\" :\"Successfully deployed spinnaker version: 1.13.6 in namespace: $namespace with the ip address:\", \"ipaddress\" : \"""$ip_address""\",\"port\":\"$deck_Port\" }"
exit 1;	  
    
 	

6. 	Entering into spin pod
  $kubectl exec -it podname /bin/bash -n namespace
  It will look like below
	$ kubectl exec -it spin-halyard-74fdfc9cdd-8rg98 /bin/bash -n dvrns
	$ hal config
	$ hal version list
	$ hal config version edit --version 1.13.5
	$ hal deploy apply
	
7. 	$ kubectl patch svc spin-deck --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n dvrns
	$ kubectl patch svc spin-gate --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n dvrns
		service/spin-deck patched
	$ kubectl get svc -n dvrns -o wide
	$ kubectl patch svc spin-gate --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]' -n dvrns
		service/spin-gate patched

Troubleshouting for checking pods log
  $kubectl descrbe podname -n namespace
  $kubectl logs pdename -n namespace








