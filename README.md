# theopenplatform
The official TheOpenPlatform production repository managed in a Kubernetes stack.

### Guide to Starting the Kubernetes Cluster and Accessing the Frontend and Backend (manual)
## Prerequisites

Before starting, ensure you have the following tools installed on your local machine:

- **kubectl**: Command-line tool for interacting with the Kubernetes cluster.
- **minikube**: A tool to run Kubernetes locally.

## Steps to Start the Kubernetes Cluster

1. **Start Minikube**: 
   Open your terminal and start Minikube with the following command:
   ```bash
   minikube start
   ```

2. **Connect Docker Daemon with Minikube**: 
   To connect the Docker daemon with Minikube, run the following command:
   ```bash
   eval $(minikube docker-env)
   ```

3. **Enable Ingress Addon in Minikube**:
   If you are using Minikube, enable the ingress addon. Remember the IP it tells you it is running on (probably 127.0.0.1):
   ```bash
   minikube addons enable ingress
   ```

5. **Build the Needed Docker Images Locally**: 
   Build the needed Docker images locally:
   ```bash
   docker build -t openplatform-database-k8s:latest -f ./database/Dockerfile ./database
   docker build -t openplatform-frontend-k8s:latest -f ./frontend/Dockerfile --target production ./frontend
   docker build -t openplatform-backend-k8s:latest -f ./backend/Dockerfile --target production ./backend
   ```

6. **Deploy the Database**:
   Apply the database deployment and service configurations:
   ```bash
   kubectl apply -f k8s/database/database-deployment.yaml
   kubectl apply -f k8s/database/database-service.yaml
   ```

7. **Deploy the Frontend**:
   Apply the frontend deployment and service configurations:
   ```bash
   kubectl apply -f k8s/frontend/frontend-deployment.yaml
   kubectl apply -f k8s/frontend/frontend-service.yaml
   ```

8. **Deploy the Backend**:
   Apply the backend deployment and service configurations:
   ```bash
   kubectl apply -f k8s/backend/backend-deployment.yaml
   kubectl apply -f k8s/backend/backend-service.yaml
   ```

10. **Set Up Ingress**:
   Apply the ingress configuration to route traffic to the frontend and backend:
   ```bash
   kubectl apply -f k8s/ingress-config.yaml
   ```

## Accessing the Frontend and Backend

1. **Check Ingress Service Type**:
   Check if the service ingress-nginx-controller is already of type LoadBalancer. If it is, you can skip the next step:
   ```bash
   kubectl get services -n ingress-nginx
   ```

2. **Patch the Ingress Controller to LoadBalancer**:
   If needed, patch the ingress-nginx-controller service to type LoadBalancer. 
   
   **Important**: This should only be done in a dev environment. In production you want to rely on a real loadbalancer.
   ```bash
   kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'
   ```

3. **Run Minikube Tunnel**:
   Run the Minikube tunnel to expose the ingress controller:
   ```bash
   minikube tunnel
   ```

4. **Edit Your Hosts File**:
   Add entries to your `/etc/hosts` file (or `C:\Windows\System32\drivers\etc\hosts` on Windows) to map the ingress IP to the frontend hosts (IP you should remember from earlier):
   ```
   <ingress-ip> theopenplatform.local
   ```

5. **Access the Frontend**:
   Open a web browser and navigate to `http://theopenplatform.local`. You should see the frontend application running.

6. **Access the Backend**:
   Open a web browser and navigate to `http://theopenplatform.local/api/v1/`. You should see a response.

## Troubleshooting

- If you encounter issues, check the status of your pods, services, etc.:
  ```bash
  kubectl get pods
  kubectl get services
  kubectl get ingress
  kubectl get deployments
  ```

- If you rebuilt an image you have to restart the pod's deployment:
  ```bash
  kubectl rollout restart deployment/<name>-deployment
  ```

- To list all namespaces:
  ```bash
  kubectl get namespaces
  ```

- For everything in a namespace:
  ```bash
  kubectl get all -n <namespace>
  ```

- For very detailed information about a resource:
  ```bash
  kubectl describe <resource-type> <resource-name>
  ```

- For logs, use:
  ```bash
  kubectl logs <pod-name>
  ```
