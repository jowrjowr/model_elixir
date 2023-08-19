module "public_loadbalancer" {
  source              = "app.terraform.io/company/public_loadbalancer/aws"
  project             = "model_elixir"
  environment         = var.environment
  subdomain           = "api"
  vpc_id              = module.networking-vpc.vpc_id
  zone_id             = data.terraform_remote_state.global.outputs.primary_zone_id
  slack_alert_sns_arn = data.terraform_remote_state.global.outputs.slack_alert_sns_arn
  asg_id              = module.ec2_asg.asg_id
  lb_subnets          = module.networking-public_subnet.subnets
  lb_alarms           = var.lb_alarms
  deletion_protection = var.deletion_protection
}
