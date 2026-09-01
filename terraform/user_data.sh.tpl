#!/bin/bash

set -e

dnf update -y

dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

mkdir -p /opt/imageforge

echo "ImageForge EC2 bootstrap completed" > /opt/imageforge/bootstrap.log
echo "AWS Region: ${aws_region}" >> /opt/imageforge/bootstrap.log