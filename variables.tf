variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "The AWS profile to use."
  type        = string
  default     = "default"
}

variable "node_type" {
  description = "The node type to use for the Redshift cluster."
  type        = string
  default     = "dc2.large"
}

variable "cluster_identifier" {
  description = "The identifier for the Redshift cluster."
  type        = string
  default     = "tf-redshift-cluster"
}

variable "database_name" {
  description = "The name of the database to create during cluster creation."
  type        = string
  default     = "analytics"
}

variable "master_username" {
  description = "The master username for the Redshift cluster."
  type        = string
  default     = "remote_admin"
}

variable "password_length" {
  description = "The length of the password to generate."
  type        = number
  default     = 16
}

variable "password_special" {
  description = "Whether to include special characters in the generated password."
  type        = bool
  default     = true
}

variable "cluster_type" {
  description = "The type of cluster to create."
  type        = string
  default     = "single-node"
}

variable "statements" {
  description = "The list of SQL statements to execute after the cluster is created, used to add additional databases and roles."
  type = list(object({
    name = string
    sql  = string
  }))
  default = [
    { name = "create_analytics_database", sql = "CREATE DATABASE RAW_LANDING" },
    { name = "create_sandbox_database", sql = "CREATE DATABASE SANDBOX" },
    { name = "create_dbt_developer_role", sql = "CREATE ROLE DBT_DEVELOPER" },
    { name = "create_analyst_role", sql = "CREATE ROLE ANALYST" },
    { name = "create_transformer_role", sql = "CREATE ROLE TRANSFORMER" }
  ]
}
