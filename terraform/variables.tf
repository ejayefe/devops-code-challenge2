variable "aws_region" {
  description = "AWS region for infrastructure provisioning"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the AWS EKS cluster"
  type        = string
  default     = "tech-challenge-2-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_type" {
  description = "EC2 Instance type required by Tech Challenge 2"
  type        = string
  default     = "t3.small"
}

variable "node_min_size" {
  description = "Minimum active node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count permitted under autoscaling"
  type        = number
  default     = 4
}