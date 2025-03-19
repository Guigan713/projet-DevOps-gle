provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.2.0/24"
}

# Security group public (frontend, bastion host et reverse proxy)
resource "aws_security_group" "sg_public" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["92.141.143.116"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.sg_private.id]
  }
}

# Security group privé (Backend, DB, Monitoring)
resource "aws_security_group" "sg_private" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = [aws_security_group.sg_public.id]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.sg_public.id]
    }

    # DB
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.sg_private.id]
    }

    # monitoring
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["92.141.143.116"]
    }

    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = ["92.141.143.116"]
    }

    ingress {
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = ["92.141.143.116"]
    }
}

resource "aws_instance" "frontend" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    subnet_id = aws.subnet.public_subnet.id
    security_groups = [aws_security_group.sg_public.id]

    tags = {
        Name = "Frontend-ReactJS"
    }
}

resource "aws_instance" "reverse_proxy" {
  ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    subnet_id = aws.subnet.public_subnet.id
    security_groups = [aws_security_group.sg_public.id]

    tags = {
        Name = "Reverse-Proxy"
    }
}

resource "aws_instance" "bastion" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    subnet_id = aws.subnet.public_subnet.id
    security_groups = [aws_security_group.sg_public.id]

    tags = {
        Name = "Bastion-Host"
    }
}

resource "aws_instance" "backend" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    subnet_id = aws.subnet.private_subnet.id
    security_groups = [aws_security_group.sg_private.id]

    tags = {
        Name = "Backend-NodeJS"
    }
}

resource "aws_instance" "database" {
  ami             = "ami-04b4f1a9cf54c11d0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.sg_private.id]

  tags = {
    Name = "Database-MySQL"
  }
}

resource "aws_instance" "monitoring" {
  ami             = "ami-04b4f1a9cf54c11d0"
  instance_type   = "t2.medium"
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.sg_private.id]

  tags = {
    Name = "Monitoring"
  }
}