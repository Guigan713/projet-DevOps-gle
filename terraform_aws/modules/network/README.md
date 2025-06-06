# Networks AWS

Ce module Terraform crée une infrastructure réseau de base sur AWS, composée d'un VPC, d'une gateway Internet, d'un subnet publique, d'un subnet privé, et de la table de routage associée au subnet public.

## main.tf

### Resources

> [!NOTE]
> - **VPC** : Un Virtual Private Cloud principal, avec un bloc CIDR configurable.
> - **Internet Gateway** : Attachée au VPC pour permettre l'accès à Internet au subnet public.
> - **Subnet public** : Un subnet configuré pour assigner automatiquement des IP publiques aux instances au lancement.
> - **Subnet privé** : Un subnet isolé, sans accès direct à Internet.
> - **Table de routage publique** : Permet le routage des IP publiques à travers l'Internet Gateway.
> - **Association de la table de routage** : Associe le subnet public à la table de routage publique.


## variables.tf

> [!NOTE]
> - **vpc_cidr** : CIDR block pour la VPC -> "10.0.0.0/16"
> - **public_subnet_cidr** : CIDR block pour le subnet public -> "10.0.1.0/24"
> - **private_subnet_cidr** : CIDR block pour le subnet privé -> "10.0.2.0/24"

> [!WARNING]
> - Ce module ne crée pas de NAT Gateway ni de table de routage privée pour le subnet privé. Les instances placées dans le subnet privé ne pourront donc pas accéder à Internet

## outputs.tf

> [!NOTE]
> - **vpc_id** : ID du VPC
> - **public_subnet_id** : ID du subnet public
> - **private_subnet_id** : ID du subnet privé