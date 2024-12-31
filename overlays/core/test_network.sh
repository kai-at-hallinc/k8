#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <resource group>"
fi

# Access command line parameters
RESOURCE_GROUP=$1

# get vnet name
VNET_NAME=$(az network vnet list --resource-group $RESOURCE_GROUP --query '[0].name' -o tsv)
