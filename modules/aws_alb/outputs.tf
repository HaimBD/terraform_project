# v9 outputs (see README "Outputs")
output "alb_arn"  { value = module.alb.arn }
output "alb_dns"  { value = module.alb.dns_name }

# Full map of TGs the module reports (handy for debugging)
output "target_groups" {
  value = module.alb.target_groups
}

# Commonly useful: the ARN of the "app" TG we created
output "app_target_group_arn" {
  value = module.alb.target_groups["app"].arn
}
