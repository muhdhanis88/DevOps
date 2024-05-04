import logging
import subprocess
from pathlib import Path
from kubernetes import client, config

# Setup logging
logging.basicConfig(level=logging.INFO)

# Current directory
nsdir = Path.cwd()
logging.info("Namespace file in this path: %s", nsdir)

def list_namespaces():
    # Load kube config
    config.load_kube_config()

    # Create API client
    v1 = client.CoreV1Api()

    # List namespaces
    with open("namespaces.txt", "w") as file:
        file.write("Namespaces:\n")
        try:
            ret = v1.list_namespace()
            excluded_patterns = ['kube', 'system', 'prometheus', 'default', 'power', 'twistlock', 'upgrade', 'ppdm', 'test', 'cert', 'thanos']
            for ns in ret.items:
                if not any(pattern in ns.metadata.name for pattern in excluded_patterns):
                    file.write(f"{ns.metadata.name}\n")
        except Exception as e:
            logging.error("Failed to list namespaces: %s", e)

def list_rabbitmq_clusters():
    # Read namespaces from namespaces.txt
    with open("namespaces.txt", "r") as file:
        namespaces = file.read().splitlines()

    # Iterate over namespaces and list RabbitMQ clusters
    for namespace in namespaces:
        try:
            rabbitmq_name_output = subprocess.check_output(["kubectl", "-n", namespace, "get", "rabbitmqcluster", "--no-headers"])
            rabbitmq_names = rabbitmq_name_output.decode().split()
            # Extract RabbitMQ cluster names from the output
            rabbitmq_cluster_names = [name for i, name in enumerate(rabbitmq_names) if i % 2 == 0]
            with open("namespaces.txt", "a") as file:
                file.write(f"RabbitMQ Clusters in Namespace '{namespace}':\n")
                for cluster_name in rabbitmq_cluster_names:
                    file.write(f"{cluster_name}\n")
            logging.info(f"RabbitMQ cluster names in Namespace '{namespace}' written to namespaces.txt")
        except subprocess.CalledProcessError as e:
            logging.error(f"Error running kubectl command for Namespace '{namespace}': %s", e.output.decode())

if __name__ == "__main__":
    list_namespaces()
    list_rabbitmq_clusters()
