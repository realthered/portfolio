#!/bin/bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login using managed identity
az login --identity

# Get VM instance metadata
INSTANCE_ID=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/vmId?api-version=2021-02-01&format=text")
NIC_NAME=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/macAddress?api-version=2021-02-01&format=text" | tr -d ':')

# Associate Static Public IP to NIC (optional - VMSS already assigns public IP per instance)
# az network nic ip-config update \
#   --resource-group ${resource_group} \
#   --nic-name $NIC_NAME \
#   --name ipconfig1 \
#   --public-ip-address ${public_ip_name}

# Install and start Apache
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Create index page
echo "<h1>Hello from ${app_name}</h1>" | sudo tee /var/www/html/index.html
