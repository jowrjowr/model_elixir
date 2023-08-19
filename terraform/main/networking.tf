module "networking-vpc" {
  source               = "app.terraform.io/company/networking-vpc/aws"
  cidr_block           = data.terraform_remote_state.global.outputs.cidr_api
  primary_zone_name    = "company.com"
  project              = "model_elixir"
  environment          = var.environment
  flow_logging_enabled = false
}

module "networking-public_subnet" {
  source      = "app.terraform.io/company/networking-public_subnet/aws"
  project     = "model_elixir"
  environment = var.environment
  vpc_id      = module.networking-vpc.vpc_id
}

# database networking

module "database-networking-vpc" {
  source               = "app.terraform.io/company/networking-vpc/aws"
  cidr_block           = data.terraform_remote_state.global.outputs.cidr_database
  primary_zone_name    = "company.com"
  project              = "model_elixir"
  name                 = "database"
  environment          = var.environment
  flow_logging_enabled = false
}

module "database-networking-public_subnet" {
  source      = "app.terraform.io/company/networking-public_subnet/aws"
  project     = "model_elixir"
  name        = "database"
  environment = var.environment
  vpc_id      = module.database-networking-vpc.vpc_id
}
