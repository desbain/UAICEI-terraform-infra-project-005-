# CREATING A ROUTE53 RECORD FOR THE LOAD BALANCER

resource "aws_route53_record" "dns_record" {
  zone_id = var.route53_zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.jupiter_app_lb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}