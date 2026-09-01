#!/bin/bash

set -e

dnf update -y
dnf install -y docker awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

mkdir -p /opt/imageforge

cat > /opt/imageforge/deploy.sh <<'DEPLOY'
#!/bin/bash

set -e

AWS_REGION="${aws_region}"
S3_BUCKET="${s3_bucket}"
ECR_REPOSITORY="${ecr_repository}"
ECR_REGISTRY="${ecr_registry}"

IMAGE="$${ECR_REGISTRY}/$${ECR_REPOSITORY}:latest"

aws ecr get-login-password --region "$${AWS_REGION}" | \
docker login \
  --username AWS \
  --password-stdin "$${ECR_REGISTRY}"

docker pull "$${IMAGE}"

docker rm -f imageforge 2>/dev/null || true

docker run -d \
  --name imageforge \
  --restart unless-stopped \
  -p 5000:5000 \
  -e AWS_REGION="$${AWS_REGION}" \
  -e S3_BUCKET="$${S3_BUCKET}" \
  "$${IMAGE}"

echo "ImageForge deployment completed."
DEPLOY

chmod +x /opt/imageforge/deploy.sh

echo "ImageForge EC2 bootstrap completed" > /opt/imageforge/bootstrap.log
echo "AWS Region: ${aws_region}" >> /opt/imageforge/bootstrap.log
