# object storage

module "nix-binary-cache" {
  source                  = "app.terraform.io/company/s3_deployment/aws"
  project                 = "model_elixir"
  name                    = "nix-binary-cache"
  vpc_id                  = module.networking-vpc.vpc_id
  environment             = var.environment
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "static_assets" {
  source              = "app.terraform.io/company/s3_deployment/aws"
  project             = "model_elixir"
  name                = "static"
  cors_allowed_origin = ["*"]
  vpc_id              = module.networking-vpc.vpc_id
  environment         = var.environment
}

module "nix-channel" {
  source                  = "app.terraform.io/company/s3_deployment/aws"
  project                 = "model_elixir"
  name                    = "nix-channel"
  website                 = true
  website_index_document  = "channel"
  vpc_id                  = module.networking-vpc.vpc_id
  environment             = var.environment
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
