output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_policy_read_write_arn" {
  description = "ARN of the IAM policy for read/write access to the bucket"
  value       = aws_iam_policy.bucket_policy_read_write.arn
}

output "bucket_policy_read_write_id" {
  description = "ID of the IAM policy for read/write access to the bucket"
  value       = aws_iam_policy.bucket_policy_read_write.id
}

