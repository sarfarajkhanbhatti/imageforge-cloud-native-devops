locals {
  project_name = "imageforge"
  environment  = "dev"

  common_tags = {
    Project     = "imageforge"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}