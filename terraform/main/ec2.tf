data "template_file" "api_backend_user_data" {
  template = file("../../configuration/api_backend.nix")
  vars = {
    binary_cache_public_key = file(var.binary_cache_public_key)
    s3_deployment_bucket    = module.nix-channel.s3_bucket
    s3_binary_bucket        = module.nix-binary-cache.s3_bucket
    environment             = var.environment
  }
}

data "aws_ami" "nixos" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.nixos_version]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["080433136561"] # nixos
}

data "aws_iam_policy_document" "manual_secrets" {

  version = "2012-10-17"
  statement {
    sid = "AllowSecrets"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.manual_secrets.arn
    ]
    effect = "Allow"
  }
}
data "aws_iam_policy_document" "s3_stuff" {

  version = "2012-10-17"

  statement {
    sid    = "S3List"
    effect = "Allow"
    actions = [
      "s3:List*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ControlStaticAssets"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${module.static_assets.s3_bucket}/*"
    ]
  }
}
data "aws_route53_zone" "domain" {
  zone_id = data.terraform_remote_state.global.outputs.primary_zone_id
}
data "aws_ses_domain_identity" "domain" {
  domain = data.aws_route53_zone.domain.name
}
data "aws_iam_policy_document" "ses_policy" {

  version = "2012-10-17"

  statement {
    sid    = "AllowSendingEmails"
    effect = "Allow"
    actions = [
      "SES:SendEmail",
      "SES:SendRawEmail"
    ]
    resources = [
      data.aws_ses_domain_identity.domain.arn
    ]
  }
}

data "aws_iam_policy_document" "assume_ingestion" {

  version = "2012-10-17"

  statement {
    sid    = "AllowIngestionAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${data.terraform_remote_state.global.outputs.customer_data_ingestion_account_id}:role/model_elixir/${var.environment}/model_elixir_data_ingestion_${var.environment}"
    ]
  }
}

module "ec2_asg" {
  source                         = "app.terraform.io/company/ec2_asg/aws"
  project                        = "model_elixir"
  environment                    = var.environment
  vpc_id                         = module.networking-vpc.vpc_id
  db_username                    = postgresql_role.model_elixir_iam.name
  ec2_ami                        = data.aws_ami.nixos.id
  ec2_instance_type              = var.api_instance
  ec2_key_name                   = var.key_name
  ec2_user_data                  = data.template_file.api_backend_user_data.rendered
  ec2_additional_security_groups = [aws_security_group.api_backend.id, aws_security_group.debug_ssh.id]
  asg_desired_capacity           = 1
  asg_min_size                   = 1
  asg_max_size                   = 1
  asg_subnets                    = module.networking-public_subnet.subnets
  asg_health_check_type          = "EC2"
  alb_target_group_id            = module.public_loadbalancer.alb_target_group_arn
  ec2_policies = {
    s3_stuff         = data.aws_iam_policy_document.s3_stuff.json
    ses_policy       = data.aws_iam_policy_document.ses_policy.json
    manual_secrets   = data.aws_iam_policy_document.manual_secrets.json
    assume_ingestion = data.aws_iam_policy_document.assume_ingestion.json
  }
}
