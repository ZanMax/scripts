#!/bin/bash

# Ask for user input
echo "Please enter the details for your Kubernetes deployment:"

read -p "Domain: " DOMAIN
read -p "App Name: " APP_NAME
read -p "Docker Image: " IMAGE

# Define placeholders and filenames
PLACEHOLDER_DOMAIN="<DOMAIN>"
PLACEHOLDER_APP_NAME="<APP_NAME>"
PLACEHOLDER_IMAGE="<IMAGE>"

DEPLOYMENT_FILE="deployment.yaml"
SERVICE_FILE="service.yaml"
INGRESS_FILE="ingress.yaml"

# Replace placeholders in the deployment file
sed -i "s|$PLACEHOLDER_DOMAIN|$DOMAIN|g" $DEPLOYMENT_FILE
sed -i "s|$PLACEHOLDER_APP_NAME|$APP_NAME|g" $DEPLOYMENT_FILE
sed -i "s|$PLACEHOLDER_IMAGE|$IMAGE|g" $DEPLOYMENT_FILE

# Replace placeholders in the service file
sed -i "s|$PLACEHOLDER_APP_NAME|$APP_NAME|g" $SERVICE_FILE

# Replace placeholders in the ingress file
sed -i "s|$PLACEHOLDER_DOMAIN|$DOMAIN|g" $INGRESS_FILE
sed -i "s|$PLACEHOLDER_APP_NAME|$APP_NAME|g" $INGRESS_FILE

echo "Kubernetes manifests have been updated."
