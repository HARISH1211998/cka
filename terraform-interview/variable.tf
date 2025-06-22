variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to launch"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_map" {
  type = map(object({
    instance_type = string
  }))
  default = {
    "web1" = { instance_type = "t3.micro" }
    "web2" = { instance_type = "t3.micro" }
  }
}

variable "setup_commands" {
  type        = list(string)
  default     = ["uptime", "date", "hostname"]
}

variable "db_password" {
  description = "Sensitive DB password"
  type        = string
  sensitive   = true
}
variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1f0"
}

variable "enable_instance" {
  description = "Whether to enable EC2 instance creation"
  type        = bool
  default     = true
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 3
}
