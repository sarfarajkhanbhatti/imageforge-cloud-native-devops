# ImageForge — Cloud-Native Image Upload Platform

ImageForge is a cloud-native image upload platform built with Python Flask, Docker, AWS, Terraform, Jenkins, and SonarQube.

The project demonstrates a practical DevOps workflow covering application development, automated testing, containerization, Infrastructure as Code, IAM security, cloud storage, monitoring, and CI/CD.

---

## Architecture

```text
                              GitHub
                                 |
                                 v
                           Jenkins CI/CD
                                 |
              +------------------+------------------+
              |                  |                  |
              v                  v                  v
           Pytest            SonarQube         Docker Build
              |                  |                  |
              +------------------+------------------+
                                 |
                                 v
                              AWS EC2
                                 |
                         Docker Container
                                 |
                         Flask + Gunicorn
                                 |
                                 v
                            Amazon S3
                                 |
                          Image Storage

                         Amazon CloudWatch
                                 |
                          EC2 Monitoring
```

---

## Project Overview

ImageForge allows users to upload images through a Flask web application.

Uploaded images are stored in an Amazon S3 bucket using UUID-based object names.

The application provides:

- Image upload
- Image validation
- Image listing
- Image deletion
- Health check endpoint
- S3-based object storage
- JSON API responses
- Docker containerization
- Terraform-based AWS infrastructure
- Jenkins CI pipeline
- SonarQube project configuration
- CloudWatch EC2 monitoring

---

## Technology Stack

### Application

- Python 3.12
- Flask
- Boto3
- Gunicorn

### Testing

- Pytest

### Containerization

- Docker
- Docker Compose

### AWS

- Amazon EC2
- Amazon S3
- AWS IAM
- Amazon VPC
- Internet Gateway
- Security Groups
- Amazon CloudWatch

### DevOps

- Terraform
- Jenkins
- SonarQube
- Git
- GitHub

---

# Application Features

## Image Upload

Users can upload images through the ImageForge web interface.

Supported formats:

- JPG
- JPEG
- PNG
- GIF
- WEBP

Uploaded files are stored in S3 under:

```text
images/<uuid>.<extension>
```

UUID-based object names prevent filename collisions.

---

## Image Listing

The application retrieves the list of images stored under the S3 `images/` prefix.

---

## Image Deletion

Images can be deleted from the S3 bucket through the API.

---

## Health Check

The application provides a health endpoint:

```text
GET /health
```

Example response:

```json
{
  "service": "imageforge",
  "status": "healthy"
}
```

---

# API Endpoints

## Home Page

```text
GET /
```

Returns the ImageForge web interface.

---

## Health Check

```text
GET /health
```

Example:

```json
{
  "service": "imageforge",
  "status": "healthy"
}
```

---

## Upload Image

```text
POST /upload
```

Multipart form field:

```text
file
```

Example:

```bash
curl -X POST \
  -F "file=@image.jpg" \
  http://localhost:5000/upload
```

---

## List Images

```text
GET /images
```

Example:

```bash
curl http://localhost:5000/images
```

---

## Delete Image

```text
DELETE /images/<object_key>
```

Example:

```bash
curl -X DELETE \
  http://localhost:5000/images/<object_key>
```

---

# Project Structure

```text
imageforge-cloud-native-devops/
│
├── app/
│   ├── __init__.py
│   ├── app.py
│   ├── requirements.txt
│   │
│   ├── templates/
│   │   └── index.html
│   │
│   └── tests/
│       ├── __init__.py
│       └── test_app.py
│
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── networking.tf
│   ├── s3.tf
│   ├── iam.tf
│   ├── ec2.tf
│   ├── monitoring.tf
│   ├── outputs.tf
│   ├── user_data.sh.tpl
│   └── terraform.tfvars.example
│
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── sonar-project.properties
├── .dockerignore
├── .gitignore
└── README.md
```

---

# Local Development

## Prerequisites

Install:

- Python 3.12+
- pip
- Docker
- Docker Compose
- AWS CLI
- Terraform

For CI/CD:

- Jenkins
- SonarQube

---

# Run Application Locally

## 1. Clone Repository

```bash
git clone <repository-url>
cd imageforge-cloud-native-devops
```

## 2. Create Virtual Environment

```bash
python3 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

## 3. Install Dependencies

```bash
python3 -m pip install -r app/requirements.txt
```

## 4. Configure AWS

The application requires:

```text
AWS_REGION
S3_BUCKET
```

Example:

```bash
export AWS_REGION=us-east-1
export S3_BUCKET=<your-s3-bucket>
```

AWS credentials should be provided through the AWS credential chain.

Do not hardcode AWS access keys or secret keys in the source code.

## 5. Run Application

```bash
python3 app/app.py
```

Application:

```text
http://localhost:5000
```

Health check:

```text
http://localhost:5000/health
```

---

# Testing

Run the complete test suite:

```bash
python3 -m pytest -v
```

Expected result:

```text
5 passed
```

The test suite covers:

- Home page
- Health endpoint
- Upload without file
- Upload without S3 bucket configuration
- Invalid image extension

---

# Docker

## Build Docker Image

```bash
docker build -t imageforge:test .
```

## Run Container

```bash
docker run -d \
  --name imageforge \
  -p 5000:5000 \
  -e AWS_REGION=us-east-1 \
  -e S3_BUCKET=<your-s3-bucket> \
  imageforge:test
```

## Health Check

```bash
curl http://localhost:5000/health
```

Expected:

```json
{
  "service": "imageforge",
  "status": "healthy"
}
```

## View Container Logs

```bash
docker logs imageforge
```

## Stop Container

```bash
docker rm -f imageforge
```

---

# Docker Compose

Set the S3 bucket:

```bash
export S3_BUCKET=<your-s3-bucket>
```

Validate Compose configuration:

```bash
docker compose config --quiet
```

Start the application:

```bash
docker compose up -d --build
```

Check the application:

```bash
curl http://localhost:5000/health
```

Stop the application:

```bash
docker compose down
```

---

# Terraform Infrastructure

Terraform is used to provision the AWS infrastructure.

The infrastructure includes:

- VPC
- Public subnet
- Internet Gateway
- Route table
- Route table association
- Security group
- S3 bucket
- S3 public access block
- S3 versioning
- S3 server-side encryption
- IAM role
- IAM policy
- IAM instance profile
- EC2 instance
- CloudWatch alarm

---

# Terraform Directory

```text
terraform/
├── main.tf
├── provider.tf
├── variables.tf
├── networking.tf
├── s3.tf
├── iam.tf
├── ec2.tf
├── monitoring.tf
├── outputs.tf
├── user_data.sh.tpl
└── terraform.tfvars.example
```

---

# Terraform Setup

## 1. Navigate to Terraform Directory

```bash
cd terraform
```

## 2. Initialize Terraform

```bash
terraform init
```

## 3. Format Terraform Files

```bash
terraform fmt
```

## 4. Validate Terraform Configuration

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

# Terraform Variables

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Configure:

```hcl
aws_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidr = "10.0.1.0/24"

availability_zone = "us-east-1a"

instance_type = "t3.micro"

key_name = "<your-ec2-key-pair>"

allowed_ssh_cidr = "<your-public-ip>/32"

allowed_http_cidr = "0.0.0.0/0"
```

Do not commit `terraform.tfvars` to Git.

---

# Terraform Plan

Review infrastructure before deployment:

```bash
terraform plan
```

Terraform will display the resources that will be created without modifying AWS infrastructure.

---

# Terraform Apply

Deploy the infrastructure:

```bash
terraform apply
```

Review the plan and confirm with:

```text
yes
```

---

# Terraform Outputs

View infrastructure outputs:

```bash
terraform output
```

Useful outputs include:

- VPC ID
- Public subnet ID
- Security group ID
- S3 bucket name
- EC2 instance ID
- EC2 public IP
- EC2 public DNS
- Application URL

---

# Terraform Destroy

When the project is no longer required:

```bash
terraform destroy
```

Confirm with:

```text
yes
```

This removes Terraform-managed AWS infrastructure.

---

# AWS Networking

The application uses a dedicated VPC.

```text
VPC
10.0.0.0/16
│
└── Public Subnet
    10.0.1.0/24
    │
    └── EC2
```

The public subnet is connected to the internet through an Internet Gateway.

The EC2 instance receives a public IP address.

---

# Security Group

The EC2 security group allows:

```text
SSH
Port: 22
Source: Configured SSH CIDR
```

and:

```text
ImageForge
Port: 5000
Source: 0.0.0.0/0
```

Outbound traffic is allowed.

For production, direct exposure of port 5000 should be replaced with an Application Load Balancer and HTTPS.

---

# IAM Security

The EC2 instance uses an IAM role through an instance profile.

The application does not require hardcoded AWS credentials.

The EC2 IAM policy provides only the S3 permissions required by ImageForge:

```text
s3:GetObject
s3:PutObject
s3:DeleteObject
s3:ListBucket
```

Object access is restricted to the ImageForge image path:

```text
images/*
```

This follows the principle of least privilege.

---

# S3 Security

The ImageForge S3 bucket uses:

- Public access blocking
- Server-side encryption
- Bucket versioning
- Terraform-managed configuration

Public access is blocked because uploaded images should not automatically become publicly accessible.

---

# Docker Security

The Docker container does not run the application as root.

A dedicated Linux user is created:

```text
appuser
```

The Flask application runs under this non-root user.

This reduces the impact of a potential container compromise.

---

# CI/CD Pipeline

Jenkins automates the Continuous Integration workflow.

Current pipeline:

```text
GitHub
   |
   v
Checkout
   |
   v
Install Dependencies
   |
   v
Pytest
   |
   v
Docker Build
   |
   v
Docker Health Test
```

The Jenkins pipeline verifies that:

1. Source code can be checked out.
2. Python dependencies can be installed.
3. Unit tests pass.
4. Docker image builds successfully.
5. The Docker container starts successfully.
6. The health endpoint responds successfully.

---

# Jenkins Pipeline Stages

## Checkout

Retrieves the source code from the configured source-control repository.

## Install Dependencies

Installs Python dependencies from:

```text
app/requirements.txt
```

## Unit Tests

Runs:

```bash
python3 -m pytest -v
```

## Docker Build

Builds the ImageForge Docker image.

## Docker Test

Starts the container and verifies:

```text
GET /health
```

The pipeline fails if the health check fails.

---

# SonarQube

SonarQube configuration is included in:

```text
sonar-project.properties
```

Configuration includes:

```text
Project Key:
imageforge

Project Name:
ImageForge

Source:
app

Tests:
app/tests
```

SonarQube can be integrated into Jenkins for static code analysis.

---

# Monitoring

Amazon CloudWatch monitors the EC2 instance status.

The project creates an alarm for:

```text
AWS/EC2
StatusCheckFailed
```

The alarm evaluates the EC2 status over multiple periods.

This provides basic infrastructure health monitoring.

---

# DevOps Workflow

The intended workflow is:

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    +----> Pytest
    |
    +----> SonarQube
    |
    +----> Docker Build
    |
    +----> Docker Test
    |
    v
AWS Deployment
    |
    v
EC2
    |
    v
Docker
    |
    v
Flask + Gunicorn
    |
    v
Amazon S3
```

---

# Environment Variables

The application supports:

```text
AWS_REGION
S3_BUCKET
```

Example:

```bash
export AWS_REGION=us-east-1
export S3_BUCKET=imageforge-example
```

Never commit secrets or AWS credentials to the repository.

---

# Validation Performed

The project has been locally validated with:

```text
Pytest
5 passed

Docker build
Successful

Docker container
Successful

Health endpoint
Healthy

Terraform initialization
Successful

Terraform validation
Successful

Terraform plan
15 resources to add
0 changes
0 destroys
```

---

# Current Infrastructure

The current Terraform configuration provisions:

```text
15 AWS resources
```

including:

```text
VPC
Public Subnet
Internet Gateway
Route Table
Route Table Association
Security Group
S3 Bucket
S3 Public Access Block
S3 Versioning
S3 Encryption
IAM Role
IAM Policy
IAM Instance Profile
EC2 Instance
CloudWatch Alarm
```

---

# Future Improvements

Potential production improvements include:

- Amazon ECR for Docker image storage
- Automated deployment to EC2
- Application Load Balancer
- HTTPS/TLS
- Route 53 DNS
- Private subnets
- NAT Gateway
- Auto Scaling Group
- CloudWatch application logs
- Centralized logging
- Terraform remote backend
- Remote state locking
- Blue/Green deployment
- Rolling deployments
- Automated security scanning
- Container image vulnerability scanning

---

# Cost Considerations

AWS resources may incur charges.

Review the infrastructure before deployment:

```bash
terraform plan
```

When the project is no longer required:

```bash
terraform destroy
```

Also verify that no manually created AWS resources remain outside Terraform.

---

# Security Considerations

This project follows several security practices:

- IAM role instead of AWS access keys on EC2
- Least-privilege S3 permissions
- S3 public access blocked
- S3 encryption enabled
- S3 versioning enabled
- SSH restricted using CIDR
- Docker container runs as non-root
- Terraform state excluded from Git
- Terraform variable files excluded from Git
- Environment files excluded from Git

---

# Author

## Sarfaraj Khan

DevOps / Cloud Engineer

### Skills Demonstrated

```text
AWS
Terraform
Docker
Jenkins
SonarQube
Python
Flask
Linux
Git
CI/CD
IAM
S3
EC2
VPC
CloudWatch
```

---

# License

This project is intended for educational, portfolio, and demonstration purposes.