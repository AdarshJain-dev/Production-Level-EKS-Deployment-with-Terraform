# 📘 Production-Ready EKS (v1.34) Terraform Deployment

## 📌 Overview

This repository contains Terraform code to deploy a **secure, production-grade Amazon EKS Cluster (v1.34)** in **ap-south-1**, including:

- Private EKS control plane  
- Managed node groups  
- Bastion host with SSM  
- Full VPC networking (public + private subnets)  
- IAM roles & policies  
- EKS addons (CoreDNS, kube-proxy, VPC CNI)  
- Security groups, NAT, routing  
- Step-by-step deployment & troubleshooting  

This template follows AWS best practices and is suitable for enterprise workloads.

---

## 🏗️ Architecture Diagram

Internet
|
+-- Internet Gateway (IGW)
|
VPC (10.0.0.0/16)
├─ Public Subnets (10.0.0.0/24, 10.0.1.0/24)
│ └── Bastion EC2 (SSM-enabled)
│ - No SSH keys needed
│ - Public IP
│ - Used for kubectl access
│
├─ Private Subnets (10.0.2.0/24, 10.0.3.0/24)
│ ├── EKS Control Plane ENIs (private endpoint)
│ └── EKS Managed Node Groups
│
├─ NAT Gateway (for nodes to access internet)
└─ Route Tables / NACLs / SGs

markdown
Copy code

### **Admin Flow**
Developer Laptop → SSM Session → Bastion → kubectl → Private EKS Cluster

yaml
Copy code

---

## 📁 Repository Structure

.
├─ main.tf
├─ variables.tf
├─ outputs.tf
├─ vpc.tf
├─ eks.tf
├─ nodegroups.tf
├─ iam-roles.tf
├─ security-groups.tf
├─ bastion.tf
├─ data.tf
├─ scripts/
│ ├─ bastion-userdata.sh
│ └─ update-kubeconfig.sh
├─ terraform.tfvars
└─ README.md

markdown
Copy code

---

## 🔧 Resources Created

### **VPC**
- VPC with CIDR `10.0.0.0/16`
- Public & private subnets across 2 AZs  
- Internet Gateway  
- NAT Gateway  
- Route tables & associations  

### **Security Groups**
- Bastion SG (egress: `0.0.0.0/0`)  
- EKS Cluster SG (private API access only)  
- Nodegroup SG  

### **IAM**
- Bastion instance role  
  - `AmazonSSMManagedInstanceCore`  
  - Minimal EKS permissions  
- EKS Cluster role  
- Nodegroup role  
- Custom IAM policies  

### **EKS**
- Kubernetes version **1.34**  
- Private endpoint enabled  
- Public endpoint disabled  
- Managed nodegroups  

### **Bastion Host**
- SSM-enabled EC2 instance (no SSH keys required)  
- AWS CLI + kubectl installed  
- Can access EKS API privately  

---

## 🧰 Prerequisites

Install these on your local machine:

- Terraform **v1.x**
- AWS CLI **v2**
- kubectl (optional – not needed for private cluster)
- IAM user/role with permissions to create:
  - VPC  
  - EC2  
  - EKS  
  - IAM  

---

## ⚙️ Terraform Execution

### 
```hcl
🚀 Deployment Steps
Step 1 — Initialize Terraform
terraform init

Step 2 — Validate & Plan
terraform validate
terraform plan -out plan.tfplan

Step 3 — Apply
terraform apply

⏳ Takes around 15–30 minutes to create EKS + Nodegroups.

🖥️ Step 4 — Connect to Bastion (via SSM)
From your laptop:
aws ssm start-session --target <bastion-instance-id> --region ap-south-1

🧩 Step 5 — Install kubectl on Bastion
sudo curl -L -o /usr/local/bin/kubectl \
https://s3.us-west-2.amazonaws.com/amazon-eks/1.34.0/2024-10-10/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
kubectl version --client

🔧 Step 6 — Install AWS CLI v2 (Required for EKS Authentication)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
aws --version
Configure AWS credentials:
aws configure

🔐 Step 7 — Generate kubeconfig (Inside Bastion)
aws eks update-kubeconfig --region ap-south-1 --name eks-prod-cluster
Test connection:
kubectl get nodes
kubectl get pods -A
kubectl get nodes
kubectl get pods -A
