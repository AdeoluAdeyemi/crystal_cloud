variable "hcloud_token" {
  description = "HCloud token"
  sensitive = true
  type = string
}

variable "tf_ssh_key" {
  description = "SSH public key for server access"
  type = string
  sensitive = true
}

variable "project_name" {
  description = "Name of the project"
  type = string
  default = "crystal-cloud-dpl"
}

variable "environment" {
  description = "Name of the environment"
  type = string
  default = "dev"
}

variable "hcloud_region" {
  description = "HCloud region"
  type = string
  default = "eu-central"
}

variable "vnet_cidr_block" {
  description = "CIDR block for vnet"
  type = string
  default = "10.0.0.0/16"
}

variable "resource_tag" {
  description = "Tags to set for all resources"
  type = map(string)
  default = {}
}


variable "public_subnet_count" {
  description = "Number of public subnets"
  type = number
  default = 1
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type = number
  default = 1
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets"
  type = list(string)
  default = [ 
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets"
  type = list(string)
  default = [ 
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

variable "container_port" {
  description = "Port of container"
  type = number
  default = 80
}
