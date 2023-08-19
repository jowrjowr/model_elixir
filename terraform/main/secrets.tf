resource "aws_secretsmanager_secret" "rds_root_pw" {
  name        = "${var.environment}/model_elixir/main/rds-root"
  description = "${var.environment} model_elixir RDS root password"
}

resource "aws_secretsmanager_secret" "manual_secrets" {
  name        = "${var.environment}/model_elixir/main/manual_secrets"
  description = "${var.environment} MANUALLY MANAGED model_elixir secrets"
}

resource "aws_secretsmanager_secret_version" "rds_root_pw_version" {
  secret_id     = aws_secretsmanager_secret.rds_root_pw.id
  secret_string = random_password.db_master_pass.result
}

resource "random_password" "db_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = 1
  }
}

resource "aws_secretsmanager_secret_version" "ec2_secrets" {
  secret_id = module.ec2_asg.secrets_id
  secret_string = jsonencode(tomap({
    PG_USERNAME = postgresql_role.model_elixir_iam.name
    PG_DATABASE = "model_elixir"
    PG_HOSTNAME = module.database.address
    AWS_ENV     = var.environment
  }))
}
