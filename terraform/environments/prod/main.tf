module "main" {
  source                    = "../../main"
  environment               = "prod"
  key_name                  = var.key_name
  database_instance         = "db.t3.small"
  api_instance              = "t3a.medium"
  deletion_protection       = true
  database_multi_az         = true
  database_backup_retention = 3
  apply_immediately         = false
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46"
    }
  }
}
