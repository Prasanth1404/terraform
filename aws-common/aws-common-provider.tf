# 1. Terraform and AWS provider versions
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80"
    }
  }
}

# 2. AWS region
provider "aws" {
  region = "ap-south-1"
}

# 3. EKS cluster name (must match aws-eks/aws-eks-provider.tf)
locals {
  cluster_name = "lwp-eks-cluster"
}