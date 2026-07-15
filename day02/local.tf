locals {
  project_name = "terraweek"
  environment  = "dev"

  name_prefix = format("%s-%s", local.project_name, local.environment)
}