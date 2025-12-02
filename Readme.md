📘 Production-Ready EKS (v1.34) Terraform Deployment — README.md
📌 Overview

This repository contains Terraform code to deploy a secure, production-grade Amazon EKS Cluster (v1.34) in ap-south-1, along with:

Private EKS control plane

Managed node groups

Bastion host with SSM

Full VPC networking (public + private subnets)

IAM roles & policies

EKS addons (CoreDNS, kube-proxy, VPC CNI)

Security groups, NAT, routing

Step-by-step deployment & troubleshooting

This template follows AWS best practices and supports enterprise production workloads.

🏗️ Architecture Diagram
Internet
   |
   +-- Internet Gateway (IGW)
         |
       VPC (10.0.0.0/16)
         ├─ Public Subnets (10.0.0.0/24, 10.0.1.0/24)
         │     └── Bastion EC2 (SSM-enabled)
         │           - No SSH keys needed
         │           - Public IP
         │           - Used for kubectl access
         │
         ├─ Private Subnets (10.0.2.0/24, 10.0.3.0/24)
         │     ├── EKS Control Plane ENIs (private endpoint)
         │     └── EKS Managed Node Groups
         │
         ├─ NAT Gateway (for nodes to access internet)
         └─ Route Tables / NACLs / SGs


Admin Flow

Developer Laptop → SSM Session → Bastion → kubectl → Private EKS Cluster

📁 Repository Structure
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
│   ├─ bastion-userdata.sh
│   └─ update-kubeconfig.sh
├─ terraform.tfvars
└─ README.md

🔧 Resources Created
VPC

VPC with CIDR 10.0.0.0/16

Public & Private subnets across 2 AZs

Internet Gateway

NAT Gateway

Route tables & associations

Security Groups

Bastion SG (egress: 0.0.0.0/0)

EKS Cluster SG (private access only)

Nodegroup SG

IAM

Bastion instance role (AmazonSSMManagedInstanceCore + minimal EKS policy)

EKS Cluster role

Nodegroup role

Custom minimal policies

EKS

Kubernetes version: 1.34

Private endpoint enabled

Public endpoint disabled

Managed nodegroup

Bastion

SSM-enabled EC2 instance (no SSH keys)

Access to EKS API

kubectl + awscli installed

🧰 Prerequisites
On your local machine

Terraform v1.x

AWS CLI v2

IAM user/role with permissions to create EKS, EC2, IAM, VPC

kubectl (optional, not required because cluster is private)

⚙️ Terraform Variables

Example terraform.tfvars:

region                = "ap-south-1"
cluster_name          = "eks-prod-cluster"
vpc_cidr              = "10.0.0.0/16"

public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs  = ["10.0.2.0/24", "10.0.3.0/24"]

bastion_instance_type = "t3.micro"
node_instance_type    = "t3.medium"

🚀 Deployment Steps
Step 1 — Initialize Terraform
terraform init

Step 2 — Validate & Plan
terraform validate
terraform plan -out plan.tfplan

Step 3 — Apply
terraform apply


⏳ Takes 15–30 minutes (EKS cluster creation + nodegroup).

🖥️ Step 4 — Connect to Bastion (SSM)

From your laptop:

aws ssm start-session --target <bastion-instance-id> --region ap-south-1


Inside bastion:

🧩 Step 5 — Install kubectl on Bastion
sudo curl -L -o /usr/local/bin/kubectl \
https://s3.us-west-2.amazonaws.com/amazon-eks/1.34.0/2024-10-10/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
kubectl version --client

🔧 Step 6 — Install AWS CLI v2 (required for EKS authentication)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
aws --version


If AWS not in PATH:

export PATH=$PATH:/usr/local/bin:/usr/local/aws-cli/v2/current/bin

🔐 Step 7 — Generate kubeconfig (inside bastion)
aws eks update-kubeconfig --region ap-south-1 --name eks-prod-cluster


Test:

kubectl get nodes
kubectl get pods -A

🛡️ Step 8 — Add Bastion IAM Role to EKS RBAC

Retrieve aws-auth:

kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml


Add:

mapRoles: |
  - rolearn: arn:aws:iam::<ACCOUNT_ID>:role/eks-prod-cluster-prod-bastion-role
    username: bastion
    groups:
      - system:masters


Apply:

kubectl apply -f aws-auth.yaml


Test again:

kubectl get nodes
kubectl get pods -A

🧪 Validation Checklist
Component	Check
VPC	terraform state list
Nodegroup	kubectl get nodes
Control Plane	aws eks describe-cluster
Addons	kubectl get pods -n kube-system
Bastion access	aws ssm start-session
🧯 Troubleshooting
❌ Cannot reach EKS endpoint from laptop

→ Expected. EKS is private. Must use Bastion.

❌ i/o timeout when running kubectl on bastion

→ Add Bastion SG → EKS Cluster SG (port 443) rule.

❌ You must be logged in to the server

→ Bastion IAM role not added to aws-auth ConfigMap.

❌ localhost:8080 error

→ Root user has no kubeconfig
→ Run kubectl as ssm-user or copy kubeconfig to root.

❌ invalid apiVersion "client.authentication.k8s.io/v1alpha1"

→ AWS CLI is outdated. Install AWS CLI v2.

🔒 Security Best Practices

✔ EKS Control Plane = Private
✔ Use SSM Session Manager (no SSH exposed)
✔ Least privilege IAM for bastion
✔ Nodes in private subnets
✔ No public nodegroups
✔ NAT Gateway for outbound internet
✔ SG rules restrict traffic properly

📌 Useful Commands

Start SSM Session:

aws ssm start-session --target <instance-id>


Update kubeconfig:

aws eks update-kubeconfig --region ap-south-1 --name eks-prod-cluster


Check EKS:

kubectl get nodes
kubectl get pods -A