provider "aws" {
  region = var.aws_region
}

# S3 bucket with lifecycle control
resource "aws_s3_bucket" "example" {
  bucket = "harishankar-bucket-${random_id.suffix.hex}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# EC2 Instances using for_each
resource "aws_instance" "web" {
  for_each = var.instance_map

  ami           = var.ami_id
  instance_type = each.value.instance_type
  tags = {
    Name = each.key
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Null resource with count and depends_on
resource "null_resource" "setup" {
  count = length(var.setup_commands)

  triggers = {
    command = var.setup_commands[count.index]
  }

  depends_on = [aws_instance.web]

  provisioner "local-exec" {
    command = "echo Running command: ${var.setup_commands[count.index]}"
  }
}
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app" {
  count = var.enable_instance ? var.instance_count : 0

  ami           = var.ami_id
  instance_type = "t2.micro"

  tags = {
    Name = "app-${count.index}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
