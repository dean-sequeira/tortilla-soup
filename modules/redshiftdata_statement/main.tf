variable "cluster_identifier" {
  type = string
}

variable "database" {
  type = string
}

variable "db_user" {
  type = string
}

variable "sql" {
  type = string
}


resource "aws_redshiftdata_statement" "this" {
  cluster_identifier = var.cluster_identifier
  database           = var.database
  db_user            = var.db_user
  sql                = var.sql

}