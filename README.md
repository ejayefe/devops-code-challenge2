# Tech Challenge 2 - EKS GitOps Architecture

Single-tier microservice deployment on AWS EKS using Terraform, Helm, GitHub Actions, and Argo CD.

## System Capabilities & Compliance
- **Infrastructure:** AWS EKS provisioned via Terraform with `t3.small` node group (Scales from 1 to 4 nodes).
- **Packaging:** Native Helm Chart with Ingress rules for AWS Load Balancer Controller.
- **Auto-scaling:** Pod auto-scaling via HorizontalPodAutoscaler (HPA) at >= 50% CPU/Memory utilization (1-3 pods/node).
- **Continuous Delivery:** In-cluster GitOps reconciliation via Argo CD.