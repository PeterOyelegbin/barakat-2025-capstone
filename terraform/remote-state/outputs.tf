output "terraform_state_bucket" {
  description = "Terraform remote state bucket name"
  value       = aws_s3_bucket.tf_state.bucket
}
