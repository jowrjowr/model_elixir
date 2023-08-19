data "aws_route53_zone" "domain" {
  zone_id = data.terraform_remote_state.global.outputs.primary_zone_id
}

data "aws_lb" "prod_alb" {
  name = "main-model_elixir-prod"
}

data "aws_lb_listener" "prod_alb_listener" {
  load_balancer_arn = data.aws_lb.prod_alb.arn
  port              = "443"
}

resource "aws_route53_record" "friendly_customer_cname" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "app.${data.aws_route53_zone.domain.name}"
  type    = "A"
  alias {
    name                   = data.aws_lb.prod_alb.dns_name
    zone_id                = data.aws_lb.prod_alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "friendly_customer_cname" {
  domain_name       = aws_route53_record.friendly_customer_cname.name
  validation_method = "DNS"

  tags = {
    Name = "model_elixir prod customer-friendly certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "friendly_customer_cname_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.friendly_customer_cname.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.terraform_remote_state.global.outputs.primary_zone_id
}


resource "aws_acm_certificate_validation" "friendly_customer_cname" {
  certificate_arn         = aws_acm_certificate.friendly_customer_cname.arn
  validation_record_fqdns = [for record in aws_route53_record.friendly_customer_cname_cert_validation : record.fqdn]
}

resource "aws_lb_listener_certificate" "friendly_customer_cname" {
  listener_arn    = data.aws_lb_listener.prod_alb_listener.arn
  certificate_arn = aws_acm_certificate.friendly_customer_cname.arn
}
