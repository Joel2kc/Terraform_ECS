variable "vpc_name" {
  description = "Name for the VPC"
  default     = "terraform-vpc"
}

# Internet Gateway variable
variable "igw_name" {
  description = "Name for the Internet Gateway"
  default     = "terraform-gw"
}

# NAT Gateway variables
variable "nat_gateway_name" {
  description = "Name for the NAT Gateway"
  default     = "gw NAT"
}

variable "cluster_name" {
  description = "Name for the cluster"
  default     = "app-cluster"
}

variable "task_definition_name" {
  description = "Name for the task definition family"
  default     = "testapp-task"
}

variable "service_name" {
  description = "Name for the ecs service"
  default     = "testapp-service"
}

variable "ecr_name" {
  description = "Name for the repository"
  default     = "terraform-ecr"
}