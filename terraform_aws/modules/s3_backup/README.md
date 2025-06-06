# Backup s3

Ce module Terraform permet de provisionner une infrastructure AWS destinée à la sauvegarde de bases de données MySQL sur Amazon S3, ainsi qu'à la gestion des permissions nécessaires pour les instances EC2 qui effectueront ces sauvegardes.


> - Création d'un bucket S3 dédié aux backups MySQL, nommé dynamiquement en fonction du projet.
> - Mise en place d'une politique IAM restreignant l'accès au bucket S3 aux actions nécessaires (PutObject, GetObject, ListBucket).
> - Création d'un rôle IAM attribuable à une instance EC2, permettant à cette dernière d'utiliser la politique IAM définie.
> - Déploiement d'un Instance Profile rattaché au rôle pour association facile à une instance EC2.

## main.tf

### ressources crées

> [!NOTE]
> - **aws_s3_bucket** : Bucket pour stocker les backups MySQL.
> - **aws_iam_policy** : Politique IAM autorisant la gestion du bucket de backup.
> - **aws_iam_role** : Rôle pour permettre à EC2 d'assumer les permissions.
> - **aws_iam_role_policy_attachment**: Association de la politique au rôle.
> - **aws_iam_instance_profile** : Profil d’instance pour attacher le rôle à une EC2.

## variables.tf

> - **project_name** : nom du projet a utiliser dans les ressources

## outputs.tf

> [!NOTE]
> - **instance_profile_name** : nom du profil d'instance qui fera le lien avec l'instance EC2 (database)
> - **bucket_name** : nom du bucket s3 sur lequel sera stocké les backups
