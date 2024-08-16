variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "node_type" {
  default = "dc2.large"
}

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
    length           = 16
    special          = true
    override_special = "!$%&*()-_=+[]{}<>:?"
  }
  unique_suffix = {
    length  = 6
    special = false
  }
  statements = [
    { name = "create_analytics_database", sql = "CREATE DATABASE RAW_LANDING" },
    { name = "create_sandbox_database", sql = "CREATE DATABASE SANDBOX" },
    { name = "create_dbt_developer_role", sql = "CREATE ROLE DBT_DEVELOPER" },
    { name = "create_analyst_role", sql = "CREATE ROLE ANALYST" },
    { name = "create_transformer_role", sql = "CREATE ROLE TRANSFORMER" }
  ]
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
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "analytics"
  master_username    = "remoteadmin"
  master_password    = random_password.password.result
  node_type          = var.node_type
  cluster_type       = "single-node"
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
  for_each           = {for stmt in local.statements : stmt.name => stmt}
  source             = "./modules/redshiftdata_statement"
  cluster_identifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  database           = aws_redshift_cluster.redshift_cluster.database_name
  db_user            = aws_redshift_cluster.redshift_cluster.master_username
  sql                = each.value.sql

  depends_on = [aws_redshift_cluster.redshift_cluster]
}