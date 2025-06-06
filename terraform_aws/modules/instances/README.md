# Instances AWS

## Main.tf
Dans ce module, on décrit les ressources (instances) nécessaires à notre infrastructure:

> [!NOTE]
> - Instance ec2 micro -> serveur frontend
> - Instance ec2 micro -> serveur backend
> - Instance ec2 micro -> serveur base de données
> - Instance ec2 micro -> reverse-proxy
> - Instance ec2 medium -> serveur de monitoring
> - Volume EBS monté sur le serveur de monitoring

## Variables.tf

> [!NOTE]
> - **AMI** : ID de l'AMI à utiliser pour les instances EC2
> - **public_subnet_id** : ID du sous réseau public
> - **private_subnet_id** : ID du sous réseau privé
> - **reverse_proxy_sg_id** : ID du security group Reverse proxy
> - **frontend_sg_id** : ID du security group frontend
> - **backend_sg_id** : ID du security group backend
> - **database_sg_id** : ID du security group database
> - **monitoring_sg_id** : ID du security group monitoring


## Outputs.tf

> [!NOTE]
> - frontend IP
> - backend IP
> - database IP
> - monitoring IP
> - reverse-proxy IP
