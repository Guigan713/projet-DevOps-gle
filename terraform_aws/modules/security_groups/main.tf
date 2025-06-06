# SG Reverse Proxy (public subnet)
resource "aws_security_group" "reverse_proxy" {
  name_prefix = "reverse-proxy-"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "reverse-proxy-sg"
  }
}

# SG for frontend (private subnet)
resource "aws_security_group" "frontend" {
  name_prefix = "frontend-"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  # egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

# SG for backend (private subnet)
resource "aws_security_group" "backend" {
  name_prefix = "backend-"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

# SG for Database (private subnet)
resource "aws_security_group" "database" {
  name_prefix = "database-"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Seulement vers le VPC local
  }

  tags = {
    Name = "database-sg"
  }
}

# SG for monitoring (Prometheus + Grafana) (private subnet)
resource "aws_security_group" "monitoring" {
  name_prefix = "monitoring-"
  vpc_id      = var.vpc_id

  # SSH from IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  # Grafana from IP
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  # Prometheus from IP
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${var.mon_ip}/32"]
  }

  # AlertManager from IP
  # ingress {
  #   from_port   = 9093
  #   to_port     = 9093
  #   protocol    = "tcp"
  #   cidr_blocks = ["${var.mon_ip}/32"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# communication rules between services

resource "aws_security_group_rule" "reverse_proxy_to_frontend" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend.id
  source_security_group_id = aws_security_group.reverse_proxy.id
}

resource "aws_security_group_rule" "frontend_to_backend" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "backend_to_database" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.backend.id
}

resource "aws_security_group_rule" "admin_to_database" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_group_id = aws_security_group.database.id
  cidr_blocks     = ["${var.mon_ip}/32"]
}

# monitoring rules

resource "aws_security_group_rule" "monitoring_to_reverse_proxy" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.reverse_proxy.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_to_frontend" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend.id
  source_security_group_id = aws_security_group.monitoring.id
}

# Prometheus vers frontend (métriques application si exposées)
# resource "aws_security_group_rule" "monitoring_to_frontend_metrics" {
#   type                     = "ingress"
#   from_port                = 9101  # Port pour les métriques applicatives
#   to_port                  = 9101
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.frontend.id
#   source_security_group_id = aws_security_group.monitoring.id
# }

resource "aws_security_group_rule" "monitoring_to_backend" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_to_backend_metrics" {
  type                     = "ingress"
  from_port                = 9102  # Port pour les métriques API
  to_port                  = 9102
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_to_database" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_to_database_mysql_exporter" {
  type                     = "ingress"
  from_port                = 9104
  to_port                  = 9104
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "reverse_proxy_to_grafana" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.reverse_proxy.id
}

# Optional (for debug)
resource "aws_security_group_rule" "reverse_proxy_to_prometheus" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.reverse_proxy.id
}