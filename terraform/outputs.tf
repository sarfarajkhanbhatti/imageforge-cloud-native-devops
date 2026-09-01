output "vpc_id" {
  description = "ID of the ImageForge VPC"
  value       = aws_vpc.imageforge.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the ImageForge security group"
  value       = aws_security_group.imageforge.id
}

output "s3_bucket_name" {
  description = "Name of the ImageForge S3 bucket"
  value       = aws_s3_bucket.imageforge.id
}

output "ec2_instance_id" {
  description = "ID of the ImageForge EC2 instance"
  value       = aws_instance.imageforge.id
}

output "ec2_public_ip" {
  description = "Public IP address of the ImageForge EC2 instance"
  value       = aws_instance.imageforge.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the ImageForge EC2 instance"
  value       = aws_instance.imageforge.public_dns
}

output "application_url" {
  description = "ImageForge application URL"
  value       = "http://${aws_instance.imageforge.public_ip}:5000"
}
output "ecr_repository_url" {
  description = "ECR repository URL for ImageForge"
  value       = aws_ecr_repository.imageforge.repository_url
}
