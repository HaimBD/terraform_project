output "alb_arn" {
  value = module.alb.arn
}

output "alb_dns" {
  value = module.alb.dns_name
}

output "app_target_group_arn" {
  value = module.alb.target_groups["app"].arn
}
