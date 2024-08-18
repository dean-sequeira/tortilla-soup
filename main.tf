terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

locals {
  password = {
    length           = var.password_length
    special          = var.password_special
    override_special = "!$%&*()-_=+[]{}<>:?"
  }
  unique_suffix = {
    length  = 6
    special = false
  }
}

resource "random_password" "password" {
  length           = local.password.length
  special          = local.password.special
  override_special = local.password.override_special
}

resource "random_string" "unique_suffix" {
  length  = local.unique_suffix.length
  special = local.unique_suffix.special
}

resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier  = var.cluster_identifier
  database_name       = var.database_name
  master_username     = var.master_username
  master_password     = random_password.password.result
  node_type           = var.node_type
  cluster_type        = var.cluster_type
  skip_final_snapshot = true
}

resource "aws_secretsmanager_secret" "redshift_connection" {
  description = "Redshift connect details"
  name        = "redshift_secret_${random_string.unique_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "redshift_connection" {
  secret_id = aws_secretsmanager_secret.redshift_connection.id
  secret_string = jsonencode({
    username            = aws_redshift_cluster.redshift_cluster.master_username
    password            = aws_redshift_cluster.redshift_cluster.master_password
    engine              = "redshift"
    host                = aws_redshift_cluster.redshift_cluster.endpoint
    port                = "5439"
    dbClusterIdentifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  })
}

module "execute_statements" {
  for_each           = {for stmt in var.statements : stmt.name => stmt}
  source             = "./modules/statements"
  cluster_identifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  database           = aws_redshift_cluster.redshift_cluster.database_name
  db_user            = aws_redshift_cluster.redshift_cluster.master_username
  sql                = each.value.sql

  depends_on = [aws_redshift_cluster.redshift_cluster]
}