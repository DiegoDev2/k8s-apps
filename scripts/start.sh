#!/bin/bash

# Variables
NAMESPACE="default"
GRAFANA_NAMESPACE="my-grafana"
MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' | grep -i 'Running')

echo "Starting Minikube..."
if [ -z "$MINIKUBE_STATUS" ]; then
  minikube start
else
  echo "Minikube is already running."
fi
echo "Applying Kubernetes configurations..."
kubectl apply -f ./grafana/grafana.yml
kubectl apply -f ./n8n/n8n.yml

echo "Waiting for n8n pod to be ready..."
kubectl wait --for=condition=ready pod -l app=n8n --namespace=$NAMESPACE --timeout=120s

echo "Setting up port-forward for n8n..."
kubectl port-forward service/n8n 5678:5678 --namespace=$NAMESPACE &

echo "Fetching service URLs..."
minikube service list

echo "Applications have been deployed."
echo "Access Grafana at http://localhost:3000"
echo "Access n8n at http://localhost:5678"
