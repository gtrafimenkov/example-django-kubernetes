# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Gennady Trafimenkov

variable "name" {
  description = "Name for the VPC and EKS cluster"
  default     = "cph-test"
  type        = string
}

variable "vpc-cidr" {
  description = "VPC CIDR"
  default     = "10.77.0.0/16"
}

variable "public-subnets-cidrs" {
  description = "CIDRs of public subnets"
  default = [
    "10.77.1.0/24",
    "10.77.2.0/24",
  ]
}

variable "tags" {
  description = "Set of tags that will be applied to all created resources"
  default = {
    project = "cph-test"
  }
}
