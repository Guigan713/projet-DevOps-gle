resource "aws_instance" "frontend" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_id
  security_groups             = [var.frontend_sg_id]
  associate_public_ip_address = false

  tags = {
    Name = "Frontend-ReactJS"
  }
}

resource "aws_instance" "reverse_proxy" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  security_groups             = [var.reverse_proxy_sg_id]
  associate_public_ip_address = true

  tags = {
    Name = "Reverse-Proxy"
  }
}

resource "aws_instance" "backend" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_id
  security_groups             = [var.backend_sg_id]
  associate_public_ip_address = false

  tags = {
    Name = "Backend-NodeJS"
  }
}

resource "aws_instance" "database" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_id
  security_groups             = [var.database_sg_id]
  associate_public_ip_address = false
  iam_instance_profile = var.instance_profile_name

  tags = {
    Name = "Database-MySQL"
  }
}

resource "aws_instance" "monitoring" {
  ami                         = var.ami
  instance_type               = "t2.medium"
  subnet_id                   = var.private_subnet_id
  security_groups             = [var.monitoring_sg_id]
  associate_public_ip_address = false

  tags = {
    Name = "Monitoring"
  }
}

resource "aws_ebs_volume" "monitoring_data" {
  availability_zone = aws_instance.monitoring.availability_zone
  size = 10
  type = "gp3"

  tags = {
    Name = "monitoring-data"
  }
}

resource "aws_volume_attachment" "monitoring_data_attach" {
  device_name = "/dev/sdf"
  volume_id = aws_ebs_volume.monitoring_data.id
  instance_id = aws_instance.monitoring.id
}

# resource "aws_ebs_volume" "backend_data" {
#   availability_zone = aws_instance.backend.availability_zone
#   size = 10
#   type = "gp3"

#   tags = {
#     Name = "backend-data"
#   }
# }

# resource "aws_volume_attachment" "back_data_attach" {
#   device_name = "/dev/sdf"
#   volume_id = aws_ebs_volume.backend_data.id
#   instance_id = aws_instance.backend.id
# }

# resource "aws_ebs_volume" "db_data" {
#   availability_zone = aws_instance.database.availability_zone
#   size = 20
#   type = "gp3"

#   tags = {
#     Name = "db-data"
#   }
# }

# resource "aws_volume_attachment" "db_data_attach" {
#   device_name = "/dev/sdf"
#   volume_id = aws_ebs_volume.db_data.id
#   instance_id = aws_instance.db.id
# }
