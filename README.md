# Tech Challenge 2 - Application Deployment: Containerization, IaC, K8s & CI/CD

A production-ready, fully automated infrastructure and application deployment pipeline built with **Terraform**, **AWS (EKS, ECR, VPC, ALB, S3)**, **GitHub Actions**, **Kubernetes**, and **Argo CD**.

---

## Architecture & Workflow Overview

The architecture follows a **GitOps-based deployment model**, where infrastructure and application deployments are automated through code and managed through Git.

### High-Level Workflow

```text
Developer
    │
    ▼
GitHub Repository
    │
    ├──────────────────────────────┐
    │                              │
    ▼                              ▼
Terraform Code               Application Code
    │                              │
    ▼                              ▼
GitHub Actions               GitHub Actions
    │                              │
    ▼                              ▼
AWS Infrastructure             Docker Build
    │                              │
    │                              ▼
    │                            Amazon ECR
    │                              │
    │                              ▼
    │                         Kubernetes / EKS
    │                              │
    │                              ▼
    │                           Argo CD
    │                              │
    └───────────────┬──────────────┘
                    ▼
             AWS Application
```

### AWS Infrastructure

The infrastructure is provisioned using **Terraform** and includes:

- **Amazon VPC** – Provides the network foundation.
- **Amazon EKS** – Managed Kubernetes cluster running the application.
- **Amazon ECR** – Container registry for Docker images.
- **Application Load Balancer (ALB)** – Provides external access to the application.
- **Amazon S3** – Provides object storage and Terraform remote state.
- **IAM** – Controls permissions between AWS services and workloads.

### Deployment Model

The deployment process is separated into two major areas:

#### 1. Infrastructure Deployment

Terraform provisions and manages the AWS infrastructure.

GitHub Actions can be used to automate Terraform operations.

#### 2. Application Deployment

GitHub Actions builds the application Docker image and pushes it to Amazon ECR.

Kubernetes manifests define the desired application state, while Argo CD monitors Git and synchronizes that desired state with the EKS cluster.

### GitOps Flow

```text
Application Code
       │
       ▼
    GitHub
       │
       ▼
GitHub Actions
       │
       ▼
Docker Image
       │
       ▼
    Amazon ECR
       │
       │
       │      Kubernetes Manifests
       │             │
       │             ▼
       │          GitHub
       │             │
       │             ▼
       └────────►  Argo CD
                     │
                     ▼
                  Amazon EKS
                     │
                     ▼
              Running Application
```

### End-to-End Deployment Flow

The intended automated workflow is:

```text
Developer Push
      │
      ▼
GitHub Repository
      │
      ▼
GitHub Actions
      │
      ├── Build Docker Image
      │
      ├── Push Image → Amazon ECR
      │
      └── Update Kubernetes Image Reference
                    │
                    ▼
              Git Repository
                    │
                    ▼
                 Argo CD
                    │
                    ▼
                 Amazon EKS
                    │
                    ▼
             Running Application
```

### Key Principle

The **Git repository is the source of truth** for the desired state of the application.

Instead of manually connecting to the Kubernetes cluster and deploying applications, changes are committed to Git. **Argo CD detects those changes and synchronizes the EKS cluster to match the state defined in Git.**

---

## Technology Stack

| Category | Technology |
|---|---|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| Containerization | Docker |
| Container Registry | Amazon ECR |
| Container Orchestration | Kubernetes |
| Kubernetes Platform | Amazon EKS |
| CI/CD | GitHub Actions |
| GitOps | Argo CD |
| Networking | Amazon VPC |
| Load Balancing | Application Load Balancer |
| Object Storage | Amazon S3 |
| Version Control | Git / GitHub |

---

## Architecture Goals

This project demonstrates:

- Infrastructure as Code using Terraform
- Automated infrastructure deployment
- Containerized application deployment
- Kubernetes orchestration
- AWS EKS cluster management
- Docker image management with ECR
- CI/CD using GitHub Actions
- GitOps using Argo CD
- Automated Kubernetes deployments
- AWS networking and load balancing
- Separation of infrastructure and application deployment
- Git as the source of truth for application state

---

## Setup & Deployment Steps

### 1. Provision Infrastructure with Terraform

Navigate to the `terraform/` directory to initialize and provision the AWS cloud infrastructure, including the VPC, EKS cluster, ECR repository, and supporting resources.

```bash
cd terraform

# Initialize Terraform and configure the remote S3 backend
terraform init

# Review the infrastructure changes
terraform plan

# Provision the AWS infrastructure
terraform apply -auto-approve
```

---

### 2. Configure Local Kubernetes Access

Once the EKS cluster has been created, configure your local AWS CLI to communicate with the cluster:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name <YOUR-EKS-CLUSTER-NAME>
```

Verify that Kubernetes can communicate with the EKS cluster:

```bash
kubectl get nodes
```

---

### 3. Bootstrap Argo CD

Navigate to the Argo CD directory and run the bootstrap script:

```bash
cd ../argocd

chmod +x bootstrap-argocd.sh

./bootstrap-argocd.sh
```

Apply the Argo CD application manifest:

```bash
kubectl apply -f application.yaml
```

Argo CD will then monitor the Git repository and synchronize the Kubernetes resources with the desired state defined in Git.

---

## CI/CD Pipeline with GitHub Actions

The GitHub Actions workflow is located at:

```text
.github/workflows/ci.yaml
```

The workflow runs when changes are pushed to the `main` branch.

### Pipeline Responsibilities

The pipeline:

1. Authenticates to AWS using GitHub Secrets.
2. Logs into Amazon ECR.
3. Builds the Docker image from the `./app` directory.
4. Tags the Docker image.
5. Pushes the image to Amazon ECR.
6. Updates the Kubernetes image reference when implementing the GitOps deployment flow.

The container image is pushed to:

```text
433635532699.dkr.ecr.us-east-1.amazonaws.com/hello-world-app:latest
```

### AWS Credentials

The GitHub Actions workflow requires AWS credentials to be configured as GitHub repository secrets.

Example secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

These credentials allow GitHub Actions to authenticate with AWS and interact with services such as Amazon ECR.

---

## GitOps Deployment with Argo CD

Argo CD is responsible for continuously reconciling the Kubernetes cluster with the desired state stored in Git.

The basic process is:

```text
Git Change
    │
    ▼
Argo CD Detects Change
    │
    ▼
Compare Desired State
with Current EKS State
    │
    ▼
Synchronize
    │
    ▼
Kubernetes Deployment
    │
    ▼
New Application Version
```

This removes the need for manually running Kubernetes deployment commands every time an application changes.

### Important Deployment Principle

The Docker image itself is stored in **Amazon ECR**, while the Kubernetes configuration describing which image version should run is stored in **Git**.

Therefore:

```text
Amazon ECR
    │
    │ Container Image
    ▼
Kubernetes Manifest in Git
    │
    │ Desired State
    ▼
Argo CD
    │
    ▼
EKS
```

---

## 🧪 Verification & Testing

### 1. Verify Running Pods

Check that the application pods are running:

```bash
kubectl get pods -n default
```

Example expected result:

```text
NAME                              READY   STATUS    RESTARTS   AGE
hello-world-app-xxxxxxxxx-xxxxx   1/1     Running   0          2m
```

---

### 2. Verify the Deployment

Check the Kubernetes deployment:

```bash
kubectl get deployment hello-world-app
```

Check the deployment rollout:

```bash
kubectl rollout status deployment hello-world-app
```

---

### 3. Rolling Restart

If the application uses the `latest` image tag and you need to force Kubernetes to recreate the pods:

```bash
kubectl rollout restart deployment hello-world-app
```

However, the preferred GitOps approach is to update the image reference in Git and allow **Argo CD to reconcile the change automatically**.

---

### 4. Test the Application Locally

Port-forward the Kubernetes service to your local machine:

```bash
kubectl port-forward svc/hello-world-app 3000:3000
```

Access the application in your browser:

```text
http://localhost:3000
```

Or test it using `curl`:

```bash
curl http://localhost:3000
```

---

## Project Structure

```text
root/
├── app/
│   ├── Dockerfile
│   ├── package.json
│   └── ...
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── ...
│
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
│
├── argocd/
│   ├── application.yaml
│   └── bootstrap-argocd.sh
│
├── .github/
│   └── workflows/
│       └── ci.yaml
│
└── README.md
```

---

## Security Considerations

The project uses AWS IAM and GitHub Secrets to control access to AWS resources.

Sensitive credentials should **never be committed to Git**.

The following should not be stored directly in the repository:

- AWS access keys
- AWS secret keys
- Kubernetes credentials
- Terraform state containing sensitive information
- Other application secrets

Where possible, IAM permissions should follow the **principle of least privilege**, granting only the permissions required by each component.

---

## Future Improvements

Potential improvements to the implementation include:

- Replace long-lived AWS access keys with **GitHub Actions OIDC authentication**.
- Use immutable Docker image tags instead of relying on `latest`.
- Use image digests to guarantee deployment of a specific container version.
- Add automated application testing to the CI pipeline.
- Add Terraform validation and security scanning.
- Add Kubernetes manifest validation.
- Implement automated rollback strategies.
- Add monitoring and observability using AWS and Kubernetes tooling.
- Implement separate development, staging, and production environments.

---

## Summary

This project demonstrates an end-to-end cloud engineering workflow:

```text
Infrastructure as Code
        │
        ▼
     Terraform
        │
        ▼
       AWS
        │
        ├── VPC
        ├── EKS
        ├── ECR
        ├── ALB
        └── S3
        │
        ▼
   Containerized App
        │
        ▼
   GitHub Actions
        │
        ▼
      Amazon ECR
        │
        ▼
      Git / GitOps
        │
        ▼
      Argo CD
        │
        ▼
       EKS
        │
        ▼
Running Application
```

The overall objective is to demonstrate how **Infrastructure as Code, CI/CD, containers, Kubernetes, AWS, and GitOps can work together to create a repeatable and automated cloud deployment process.**