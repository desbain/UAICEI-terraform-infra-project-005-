output "jupiter_app_tg_arn" {
 value = aws_lb_target_group.Jupiter-app-tg.arn
}

output "jupiter_app_lb_dns_name" {
 value = aws_lb.jupiter_app_lb.dns_name
}

output "alb_zone_id" {
 value = aws_lb.jupiter_app_lb.zone_id
}