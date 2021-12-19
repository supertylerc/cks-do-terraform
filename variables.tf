variable "vpc_name" {
  type        = string
  description = "Name of your DO VPC (default: $ {var.region}-vpc)"
  default     = ""
}

variable "vpc_ip_range" {
  type        = string
  description = "IPv4 CIDR for VPC"
  default     = "10.0.0.0/24"
}

variable "region" {
  type        = string
  description = "Region in which to deploy resources"
}

variable "controllers" {
  type        = map(map(string))
  description = "A map of maps describing the Kubernetes (master) controllers to be created"
}

variable "nodes" {
  type        = map(map(string))
  description = "A map of maps describing the Kubernetes (worker) nodes to be created"
}

variable "default_droplet_image" {
  type        = string
  description = "Default image slug to use if not specified in var.droplets"
  default     = "ubuntu-20-04-x64"
}

variable "default_droplet_size" {
  type        = string
  description = "Default droplet size to use if not specified in var.droplets"
  default     = "s-1vcpu-1gb"
}

variable "droplet_ssh_keys" {
  type        = map(string)
  description = "Map of public SSH keys to add to the droplets"
  default     = {}
}

variable "additional_tags" {
  type        = list
  description = "List of additional tags to apply to droplets created"
  default     = []
}

variable "project_name" {
  type        = string
  description = "DigitalOcean project name"
  default     = "cks"
}
