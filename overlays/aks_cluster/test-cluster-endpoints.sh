#!/bin/bash

# Run kubectl cluster-info and capture the output
cluster_info=$(kubectl cluster-info)

# Extract the control plane URL
control_plane_url=$(echo "$cluster_info" | grep "Kubernetes control plane" | awk '{print $NF}')
if [ -n "$control_plane_url" ]; then
    echo "control plane found"
fi

# Extract the addon-http-application-routing-nginx-ingress URLs
nginx_ingress_urls=$(echo "$cluster_info" | grep "addon-http-application-routing-nginx-ingress" | awk '{print $NF}')
if [ -n "$nginx_ingress_url" ]; then
    echo "ingress found"
fi

# Extract the CoreDNS URL
coredns_url=$(echo "$cluster_info" | grep "CoreDNS" | awk '{print $NF}')
if [ -n "coredns_url" ]; then
    echo "dsn server found"
fi

# Extract the Metrics-server URL
metrics_server_url=$(echo "$cluster_info" | grep "Metrics-server" | awk '{print $NF}')
if [ -n "metrics_server_url" ]; then
    echo "metrics server found"
fi


# check that none of the variables are empty
if [ -z "$control_plane_url" ] || [ -z "$nginx_ingress_urls" ] || [ -z "$coredns_url" ] || [ -z "$metrics_server_url" ]; then
  echo "Some endpoints missing"
  exit 1
fi