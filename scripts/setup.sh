#!/bin/bash
set -e

# 1. Start Minikube
minikube start

# 2. Connect Docker daemon to Minikube
eval $(minikube docker-env)

# 3. Enable Ingress addon
minikube addons enable ingress

# 4. Build Docker images locally
docker build -t openplatform-database-k8s:latest -f ./database/Dockerfile ./database
docker build -t openplatform-frontend-k8s:latest -f ./frontend/Dockerfile --target production ./frontend
docker build -t openplatform-backend-k8s:latest -f ./backend/Dockerfile --target production ./backend

# 5. Deploy Database
kubectl apply -f k8s/database/database-deployment.yaml
kubectl apply -f k8s/database/database-service.yaml

# 6. Deploy Frontend
kubectl apply -f k8s/frontend/frontend-deployment.yaml
kubectl apply -f k8s/frontend/frontend-service.yaml

# 7. Deploy Backend
kubectl apply -f k8s/backend/backend-deployment.yaml
kubectl apply -f k8s/backend/backend-service.yaml

# 8. Setup Ingress
kubectl apply -f k8s/ingress-config.yaml

# Optional: Check ingress-nginx-controller service type and patch if necessary
svc_type=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.type}')
if [ "$svc_type" != "LoadBalancer" ]; then
  echo "Patching ingress-nginx-controller service to type LoadBalancer..."
  kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'
fi

echo "Minikube environment setup complete."
