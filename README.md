# Tortilla-Soup 🍲

## Overview

Terraform an AWS Redshift cluster suitable for a dbt (data build tool) project.
The infrastructure includes the creation of multiple databases, roles, and users within the Redshift cluster.

## Prerequisites

- Terraform v1.0.0 or later
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create Redshift clusters and manage Secrets Manager

## Project Structure

- `.gitignore`: Specifies files and directories to be ignored by Git.
- `main.tf`: Main Terraform configuration file.
- `modules/redshiftdata_statement/main.tf`: Module for executing SQL statements on the Redshift cluster.
- `README.md`: Project documentation.

## Terraform Configuration

### Variables

- `region`: AWS region to deploy the resources (default: `us-east-1`).
- `profile`: AWS CLI profile to use (default: `default`).
- `node_type`: Type of Redshift node (default: `dc2.large`).

### Resources

- `aws_redshift_cluster`: Creates a Redshift cluster.
- `aws_secretsmanager_secret`: Stores Redshift connection details in AWS Secrets Manager.
- `aws_secretsmanager_secret_version`: Manages versions of the secret.
- `random_password`: Generates a random password for the Redshift cluster.
- `random_string`: Generates a unique suffix for the secret name.
- `aws_redshiftdata_statement`: Executes SQL statements on the Redshift cluster.

### Modules

- `redshiftdata_statement`: Executes SQL statements defined in the `local.statements` variable.

## Usage

1. **Initialize Terraform:**

   ```sh
   terraform init
   ```

2. **Plan the deployment:**

   ```sh
   terraform plan
   ```
3. **Apply the configuration:**

   ```sh
   terraform apply
   ```

4. **Destroy the resources:** (Optional - to remove all resources)

   ```sh
    terraform destroy
    ```
   
## Notes
Notes
- Ensure that sensitive data such as passwords and private keys are not committed to version control. Use `.tfvars` files for sensitive data and add them to `.gitignore`.
- Override files can be used to customize resources locally and should not be checked into version control.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
