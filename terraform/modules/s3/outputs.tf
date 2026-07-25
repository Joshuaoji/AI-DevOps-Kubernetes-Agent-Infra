output "artifacts_bucket_name" {
  description = "Name of the artifacts bucket."
  value       = try(aws_s3_bucket.artifacts[0].id, null)
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket."
  value       = try(aws_s3_bucket.artifacts[0].arn, null)
}

output "logs_bucket_name" {
  description = "Name of the logs bucket."
  value       = try(aws_s3_bucket.logs[0].id, null)
}

output "logs_bucket_arn" {
  description = "ARN of the logs bucket."
  value       = try(aws_s3_bucket.logs[0].arn, null)
}
