#!/bin/bash

# Get the directory path of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Current path: $SCRIPT_DIR"

# Define the function to get namespaces
getNamespaces() {
    kubectl get ns --no-headers | egrep -v "kube|system|prometheus|default|power|twistlock|upgrade|ppdm|test|cert|thanos" | awk '{print $1}'
}

# Define the function to get RabbitMQ clusters for a given namespace
getRabbitmqCluster() {
    namespace=$1
    kubectl -n $namespace get rabbitmqcluster --no-headers | awk '{print $1}'
}

# Define the function to edit the replica count of a RabbitMQ cluster to 0
editRabbitmqClusterReplicaCount() {
    namespace=$1
    rabbitmq_cluster=$2
    kubectl patch rabbitmqcluster $rabbitmq_cluster -n $namespace --type merge --patch '{"spec":{"replicas":0}}'
}

# Define the function to delete the StatefulSet within a namespace
deleteStatefulSet() {
    namespace=$1
    statefulset=$2
    kubectl delete sts $statefulset -n $namespace
}

# Define the function to get statefulsets
getStatefulSet() {
    namespace=$1
    kubectl -n $namespace get sts --no-headers | egrep -v "rmq-exporter-$namespace" | awk '{print $1}'
}

echo ""
# Append the provided command
for namespace in $(getNamespaces); do
    rabbitmq_name=$(getRabbitmqCluster $namespace)
    if [ -n "$rabbitmq_name" ]; then
        printf "%s %s\n" "$namespace" "$rabbitmq_name" >> namespaces.txt
		
        # Edit replica count to 0
		echo "Updating the replicas to 0"
        editRabbitmqClusterReplicaCount $namespace $rabbitmq_name
		
        # Get and delete StatefulSets
		echo "Deleting statefulset..."
        statefulsets=$(getStatefulSet $namespace)
        for statefulset in $statefulsets; do
            deleteStatefulSet $namespace $statefulset
        done
		
    fi
done
