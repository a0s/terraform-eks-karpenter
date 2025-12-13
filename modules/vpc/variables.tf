
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "intra_subnets" {
  description = "Intra subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "nat_type" {
  description = "Type of NAT to use: 'regular' for AWS NAT Gateway, 'fck' for FCK NAT"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "regular", "fck"], var.nat_type)
    error_message = "nat_type must be either 'none', 'regular' or 'fck'."
  }
}

variable "single_nat_gateway" {
  description = "Should be true to provision a single shared NAT Gateway across all private subnets. If false, one NAT Gateway per availability zone will be created."
  type        = bool
  default     = true
}

variable "fck_nat_name" {
  description = "Name for the FCK NAT"
  type        = string
  default     = "fck-nat"
}
