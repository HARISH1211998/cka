output "instance_public_ips" {
  description = "Public IPs of EC2 instances"
  value       = { for k, v in aws_instance.web : k => v.public_ip }
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.example.bucket
}

output "db_password_output" {
  description = "Sensitive output of DB password"
  value       = var.db_password
  sensitive   = true
}
