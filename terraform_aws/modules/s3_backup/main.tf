resource "aws_s3_bucket" "mysql_backup" {
  bucket        = "mysql-backup-${var.project_name}"
  force_destroy = true
  tags = {
    Name        = "MySQL Backup"
  }
}

resource "aws_iam_policy" "s3_backup_policy" {
  name        = "s3-mysql-backup-policy-prod"
  description = "Allow backup script to access S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::mysql-backup",
        "arn:aws:s3:::mysql-backup/*"
      ]
    }]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-backup-role-prod"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.project_name}-backup-profile"
  role = aws_iam_role.ec2_role.name
}
