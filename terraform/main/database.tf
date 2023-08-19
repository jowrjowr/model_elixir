# DB instance size chart:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html

# NOTE: no filter is currently applied because the VPC subnets are database
# specifc. can add a filter down the line as necessary.

# data "aws_subnet_ids" "api_database" {
#   vpc_id = module.database-networking-vpc.vpc_id
# }

data "aws_subnets" "api_database" {
  filter {
    name   = "vpc-id"
    values = [module.database-networking-vpc.vpc_id]
  }
}

module "database" {
  source               = "app.terraform.io/company/database/aws"
  project              = "model_elixir"
  engine_version       = "13.7"
  performance_insights = true
  vpc_id               = module.database-networking-vpc.vpc_id
  vpc_subnets          = data.aws_subnets.api_database.ids
  environment          = var.environment
  password             = aws_secretsmanager_secret_version.rds_root_pw_version.secret_string
  instance             = var.database_instance
  allocated_storage    = var.database_allocated_storage
  apply_immediately    = var.apply_immediately
  backup_retention     = var.database_backup_retention
  multi_az             = var.database_multi_az
  deletion_protection  = var.deletion_protection
}

# setup the IAM role so that the database bastion can log into the database

provider "postgresql" {
  host            = module.database.address
  port            = module.database.port
  database        = "postgres"
  username        = module.database.username
  password        = aws_secretsmanager_secret_version.rds_root_pw_version.secret_string
  sslmode         = "require"
  superuser       = false
  connect_timeout = 15
}

# resource "postgresql_database" "model_elixir" {
#   name       = "model_elixir"
#   owner      = "model_elixir"
#   depends_on = [postgresql_role.model_elixir]
# }

resource "postgresql_role" "model_elixir" {
  name  = "model_elixir"
  login = true
}

resource "postgresql_role" "model_elixir_iam" {
  name       = "model_elixir_iam"
  login      = true
  roles      = ["rds_iam", "model_elixir"]
  depends_on = [postgresql_role.model_elixir]
}
