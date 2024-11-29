output "attributes" {
  value       = local.attributes
  description = "Normalized attributes"
}

output "tags" {
  value       = local.tags
  description = "Normalized Tag map"
}


output "instanceTags" {
  value       = local.tags
  description = "Normalized Tag Map for EC2 instances"
}

output "autoScalingGroupTags" {
  value       = local.tags
  description = "Normalized Tag Map for EC2 instances"
}
