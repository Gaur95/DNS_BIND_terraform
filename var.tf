variable "region" {
  description = "AWS region where resources will be created"
  default     = "ap-south-1" # Change to your preferred region
}

variable "ami" {
  description = "AMI ID for Ubuntu 22.04 LTS in the selected region"
  type        = string
  default     = "ami-0dee22c13ea7a9a67" # Update based on your region
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     =  "mumbaikey" 
}

# variable "ssh_cidr" {
#   description = "CIDR block for SSH access (replace YOUR_IP with your actual IP)"
#   type        = string
#   default     = "YOUR_IP_ADDRESS/32" # Replace with your IP, e.g., "203.0.113.0/32"
# }

variable "domain" {
  description = "Your subdomain under eu.org (e.g., akash.eu.org)"
  type        = string
  default     = "akash.eu.org" # Replace with your actual subdomain
}

variable "primary_ns" {
  description = "Primary name server hostname"
  type        = string
  default     = "ns1.akash.eu.org" # e.g., ns1.akash.eu.org
}

variable "secondary_ns" {
  description = "Secondary name server hostname"
  type        = string
  default     = "ns2.akash.eu.org" # e.g., ns2.akash.eu.org
}
