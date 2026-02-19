# Project Bedrock (Baraka 3rd Semester Exam): InnovateMart's EKS Deployment
## Overview
Welcome to Project Bedrock - InnovateMart's inaugural production-grade Kubernetes deployment on AWS. This project represents the foundation of our modern e-commerce platform, transitioning from a monolithic architecture to scalable microservices running on Amazon EKS. It focuses on provisioning a secure Amazon EKS cluster and deploy the [AWS Retail Store Sample App](https://github.com/aws-containers/retail-store-sample-app). You must automate the infrastructure, secure developer access, implement observability, and extend the architecture with event-driven serverless components.

---

## Architecture Diagram
```mem
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud (us-east-1)                          │
│                                                                             │
│  ┌─────────────────────┐      ┌───────────────────────────────────────┐   │
│  │     GitHub Actions   │      │           Project Bedrock VPC         │   │
│  │     CI/CD Pipeline   │─────▶│  ┌───────────────────────────────┐   │   │
│  │  ┌───────────────┐   │      │  │         Public Subnets        │   │   │
│  │  │ PR: terraform │   │      │  │  ┌─────┐  ┌─────┐  ┌─────┐    │   │   │
│  │  │    plan       │   │      │  │  │ AZ1 │  │ AZ2 │  │ AZ3 │    │   │   │
│  │  └───────────────┘   │      │  │  └──┬──┘  └──┬──┘  └──┬──┘    │   │   │
│  │  ┌───────────────┐   │      │  │     │       │       │        │   │   │
│  │  │ Merge: terraform│   │      │  │     └───────┼───────┘        │   │   │
│  │  │    apply       │   │      │  │             │                 │   │   │
│  │  └───────────────┘   │      │  │      Internet Gateway          │   │   │
│  └──────────┬──────────┘      │  └───────────────┬─────────────────┘   │   │
│             │                 │                  │                       │   │
│             │                 │                  ▼                       │   │
│             │                 │  ┌───────────────────────────────┐       │   │
│             │                 │  │         NAT Gateway           │       │   │
│             │                 │  └───────────────┬───────────────┘       │   │
│             │                 │                  │                       │   │
│             │                 │                  ▼                       │   │
│             │                 │  ┌───────────────────────────────┐       │   │
│             │                 │  │       Private Subnets         │       │   │
│             │                 │  │  ┌─────┐  ┌─────┐  ┌─────┐    │       │   │
│             │                 │  │  │ AZ1 │  │ AZ2 │  │ AZ3 │    │       │   │
│             │                 │  │  └──┬──┘  └──┬──┘  └──┬──┘    │       │   │
│             │                 │  │     │       │       │        │       │   │
│             │                 │  │     └───────┼───────┘        │       │   │
│             │                 │  │             │                 │       │   │
│             │                 │  │    ┌────────┴────────┐        │       │   │
│             │                 │  │    │  EKS Cluster    │        │       │   │
│             │                 │  │    │project-bedrock- │        │       │   │
│             │                 │  │    │    cluster      │        │       │   │
│             │                 │  │    └────────┬────────┘        │       │   │
│             │                 │  │             │                 │       │   │
│             │                 │  │    ┌────────┴────────┐        │       │   │
│             │                 │  │    │  retail-app     │        │       │   │
│             │                 │  │    │  Namespace      │        │       │   │
│             │                 │  │    └─────────────────┘        │       │   │
│             │                 │  │           │                   │       │   │
│             │                 │  │    ┌──────┴──────┐            │       │   │
│             │                 │  │    │   Retail    │            │       │   │
│             │                 │  │    │   Store App │            │       │   │
│             │                 │  │    │ (Helm Chart)│            │       │   │
│             │                 │  │    └─────────────┘            │       │   │
│             │                 │  └───────────────────────────────┘       │   │
│             │                 │                                           │   │
│  ┌──────────┴──────────┐      │  ┌───────────────────────────────┐       │   │
│  │   S3 Event Flow     │      │  │      CloudWatch Logs          │       │   │
│  │                     │      │  │  ┌───────────────────────┐    │       │   │
│  │ ┌───────────────┐   │      │  │  │ EKS Control Plane    │    │       │   │
│  │ │ S3 Bucket:    │   │      │  │  │ - API                │    │       │   │
│  │ │ bedrock-assets│   │      │  │  │ - Audit              │    │       │   │
│  │ │ -[student-id] │   │      │  │  │ - Authenticator      │    │       │   │
│  │ └───────┬───────┘   │      │  │  │ - ControllerManager  │    │       │   │
│  │         │           │      │  │  │ - Scheduler          │    │       │   │
│  │         ▼           │      │  │  └───────────────────────┘    │       │   │
│  │ ┌───────────────┐   │      │  │  ┌───────────────────────┐    │       │   │
│  │ │   Event       │   │      │  │  │ Application Logs      │    │       │   │
│  │ │ Notification  │   │      │  │  │ retail-app containers │    │       │   │
│  │ └───────┬───────┘   │      │  │  └───────────────────────┘    │       │   │
│  │         │           │      │  └───────────────────────────────┘       │   │
│  │         ▼           │      │                                           │   │
│  │ ┌───────────────┐   │      │  ┌───────────────────────────────┐       │   │
│  │ │  Lambda:      │   │      │  │      IAM & Security           │       │   │
│  │ │ bedrock-asset-│   │      │  │  ┌───────────────────────┐    │       │   │
│  │ │ processor     │   │      │  │  │ IAM User: bedrock-    │    │       │   │
│  │ └───────┬───────┘   │      │  │  │ dev-view (ReadOnly)   │    │       │   │
│  │         │           │      │  │  └───────────────────────┘    │       │   │
│  │         ▼           │      │  │  ┌───────────────────────┐    │       │   │
│  │ ┌───────────────┐   │      │  │  │ Kubernetes RBAC:     │    │       │   │
│  │ │ CloudWatch    │   │      │  │  │ view ClusterRole     │    │       │   │
│  │ │ Logs: "Image  │   │      │  │  │ mapped to IAM user   │    │       │   │
│  │ │ received: ..."│   │      │  │  └───────────────────────┘    │       │   │
│  │ └───────────────┘   │      │  └───────────────────────────────┘       │   │
│  └─────────────────────┘      │                                           │   │
│                               └───────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites
Before you begin, ensure you have:
- AWS CLI configured with administrative access
- Terraform (v1.5+) installed
- kubectl and Helm installed
- Git and GitHub account

## Repository Structure
```text
barakat-2025-capstone/
├── .github/
│   └── workflows/
│       └── deploy-infra.yml        # GitHub Actions CI/CD pipeline
├── cluster-deps                    # Helm chart
│   ├── Chart.lock
│   ├── charts
│   │   └── dynamodb-local
│   ├── Chart.yaml
│   ├── templates
│   └── values.yaml
├── scripts                         # Deployment scripts
├── terraform/
|   ├── modules
|   │   ├── compute                 # EKS, IAM roles and users, and Lambda function
|   │   ├── networking              # VPC and networking
|   │   └── storage                 # S3 bucket
|   ├── remote-state
│   ├── main.tf                     # Main Terraform configuration
│   ├── variables.tf                # Input variables
|   ├── terraform.tfvars.example
│   └── outputs.tf                  # Output values
├── grading.json                    # Auto-generated by terraform output
└── README.md                       # This file
```

## Pipeline Trigger Instructions
1. Clone the repository
```bash
git clone https://github.com/PeterOyelegbin/barakat-2025-capstone.git
cd barakat-2025-capstone
```

2. Create a feature branch
```bash
git checkout -b feature/your-feature-name
```

3. Make changes in the Repo
- Alter any word in the `README.md` file

4. Push changes and create Pull Request
```bash
git add .
git commit -m "Describe your infrastructure changes"
git push origin feature/your-feature-name
```
- Go to GitHub and create a Pull Request to main
- This automatically triggers terraform plan (visible in PR comments)

5. Merge to Main
- After PR review and approval, merge to main
- This automatically triggers terraform apply
- Monitor the pipeline in GitHub Actions → workflow runs

6. Get the Application URL/EXTERNAL-IP
- Run the following command in your terminal:
```bash
aws eks --region us-east-1 update-kubeconfig --name project-bedrock-cluster \
    --role-arn arn:aws:iam::ACCOUNT_ID:role/project-bedrock-eks-admin-role

kubectl get svc ui -n retail-app
```

## Conclusion
I successfully automated the infrastructure pipeline, archieving a running application, centralized logging, and a secured cluster ready for developer hand-off, this shows my hand-on approach to deploying a microservice to AWS EKS provisioning the infrastructure using terraform and automating deployment using github actions.
