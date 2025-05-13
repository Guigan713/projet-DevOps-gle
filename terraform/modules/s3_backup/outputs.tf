output "instance_profile_name" {
  value = aws_iam_instance_profile.profile.name
}

output "bucket_name" {
  value = aws_s3_bucket.mysql_backup.bucket
}