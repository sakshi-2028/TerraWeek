output "name_prefix" {
  value = local.name_prefix
}

output "project_name_upper" {
  value = upper(local.project_name)
}

output "environment_length" {
  value = length(local.environment)
}