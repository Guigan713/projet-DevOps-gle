terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Créer les répertoires nécessaires sur le serveur distant
resource "null_resource" "setup_directories" {
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/myapp/{nginx,mysql,prometheus,grafana,app}",
      "mkdir -p /opt/myapp/grafana/{data,dashboards,provisioning/{dashboards,datasources}}",
      "mkdir -p /opt/myapp/prometheus/data",
      "mkdir -p /opt/myapp/mysql/data",
      "mkdir -p /opt/myapp/nginx/{conf.d,ssl}",
    ]
  }
}

# Installation de Docker et Docker Compose
resource "null_resource" "install_docker" {
  depends_on = [null_resource.setup_directories]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "systemctl enable docker",
      "systemctl start docker",
      "curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
      "usermod -aG docker $USER"
    ]
  }
}

# Copier le fichier docker-compose.yml
resource "null_resource" "copy_docker_compose" {
  depends_on = [null_resource.install_docker]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/docker-compose.yml", {
      mysql_root_password = var.mysql_root_password
      mysql_database      = var.mysql_database
      mysql_user          = var.mysql_user
      mysql_password      = var.mysql_password
      domain_name         = var.domain_name
    })
    destination = "/opt/myapp/docker-compose.yml"
  }
}

# Copier la configuration Nginx
resource "null_resource" "copy_nginx_config" {
  depends_on = [null_resource.setup_directories]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/nginx/nginx.conf", {
      domain_name = var.domain_name
    })
    destination = "/opt/myapp/nginx/nginx.conf"
  }
}

# Copier la configuration Prometheus
resource "null_resource" "copy_prometheus_config" {
  depends_on = [null_resource.setup_directories]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/prometheus.yml"
    destination = "/opt/myapp/prometheus/prometheus.yml"
  }
}

# Copier les configurations Grafana
resource "null_resource" "copy_grafana_config" {
  depends_on = [null_resource.setup_directories]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content = jsonencode({
      apiVersion = 1
      datasources = [
        {
          name   = "Prometheus"
          type   = "prometheus"
          url    = "http://prometheus:9090"
          access = "proxy"
        }
      ]
    })
    destination = "/opt/myapp/grafana/provisioning/datasources/prometheus.yml"
  }
}

# Démarrer les services
resource "null_resource" "start_services" {
  depends_on = [
    null_resource.copy_docker_compose,
    null_resource.copy_nginx_config,
    null_resource.copy_prometheus_config,
    null_resource.copy_grafana_config
  ]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/myapp",
      "docker-compose down || true",
      "docker-compose up -d"
    ]
  }

  # Redémarrer les services si la configuration change
  triggers = {
    docker_compose_sha = filesha256("${path.module}/docker-compose/docker-compose.yml")
    nginx_config_sha   = filesha256("${path.module}/nginx/nginx.conf")
  }
}

# Construire les images Docker
resource "null_resource" "build_images" {
  depends_on = [null_resource.copy_app_code]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/myapp",
      "docker-compose build --no-cache",
    ]
  }

  # Rebuild si les Dockerfiles changent
  triggers = {
    backend_dockerfile  = fileexists("${path.module}/app/backend/Dockerfile") ? filesha256("${path.module}/app/backend/Dockerfile") : ""
    frontend_dockerfile = fileexists("${path.module}/app/frontend/Dockerfile") ? filesha256("${path.module}/app/frontend/Dockerfile") : ""
    docker_compose_sha  = filesha256("${path.module}/docker-compose/docker-compose.yml")
  }
}
