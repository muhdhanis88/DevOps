#!/bin/bash

#Define path
clusterpath=/home/hanis/script/lens_cli/pks_config
clusterpath_tkgi=/home/hanis/pks_Config
clusterpathwindows="/mnt/c/Users/Hanis_Abas/OneDrive - Dell Technologies/Documents/pks_cli"

#echo $clusterpath

#:<<COMMENT
# Define the list of clusters and their API endpoints
clusters=(
  "rmq-shared-c0-v1-pks api.v1.pks.dell.com"
  "rmq-shared-c0-a1-pks api.a1.pks.dell.com"
  "cpe-tool02-s1-pks api.s1.pks.dell.com"
  "kafka-c1-s1-pks api.s1.pks.dell.com"
  "cpe-tools02-p1-pks api.p1.pks.dell.com"
  "cpe-kafka-p1-pks api.p1.pks.dell.com"
  "rmq-shared-c1-r1-pks api.r1.pks.dell.com"
  "rmq-shared-c0-r1-pks api.r1.pks.dell.com"
  "kafka-c1-l-r1-pks api.r1.pks.dell.com"
  "kafka-c0-r1-pks api.r1.pks.dell.com"
  "ipe-msg-ddc-r2-pks api.r2.pks.dell.com"
  "msg-lab-c0-r2-pks api.r2.pks.dell.com"
  "rmq-shared-c0-s2-pks api.s2.pks.dell.com"
  "rmq-shared-c0-p2-pks api.p2.pks.dell.com"
  "cpe-kafka-s1-pks api.s1.pks.dell.com"
  "kafka-p3-pks api.p3.pks.dell.com"
  "kafka-s3-pks api.s3.pks.dell.com"
  "rmq-tier1-c0-a2-pks api.a2.pks.dell.com"
  "rmq-tier1-c0-npa1-pks api.npa1.pks.dell.com"
  "rmq-tier1-c0-npp1-pks api.npp1.pks.dell.com"
  "rmq-tier1-c0-npv1-pks api.npv1.pks.dell.com"
  "rmq-tier1-c0-p3-pks api.p3.pks.dell.com"
  "rmq-tier1-c0-s3-pks api.s3.pks.dell.com"
  "rmq-tier1-c0-v2-pks api.v2.pks.dell.com"
  "rmq-share-c2-r1-npp1-pks api.npp1.pks.dell.com"
  "kafka-c0-t-npp1-pks api.npp1.pks.dell.com"
)

# Prompt user for username and password
read -p "Enter username: " username
read -s -p "Enter password: " password

# Loop through each cluster and log in
for cluster in "${clusters[@]}"; do
  # Extract the cluster name and API endpoint from the array
  cluster_name=$(echo "${cluster}" | cut -d' ' -f1)
  api_endpoint=$(echo "${cluster}" | cut -d' ' -f2)

  echo "Logging in to ${cluster_name}..."

  # Log in to the cluster and save the kubeconfig to a text file
  tkgi get-kubeconfig "${cluster_name}" -u "${username}" -a "${api_endpoint}" -k -p "${password}"
  kubectl config view --flatten=false --raw=true --minify -o yaml > "$clusterpath/${cluster_name}.txt"

 # Copy the successful file to Windows document folder
  if [ -f "$clusterpath/${cluster_name}.txt" ]; then
     cp "$clusterpath/${cluster_name}.txt" "$clusterpathwindows/${cluster_name}.txt" 
	 #cp "$clusterpath/${cluster_name}.txt" "$clusterpath_tkgi/${cluster_name}.txt"
  fi
done
#COMMENT
echo "Done."
