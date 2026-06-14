locals {
  root = read_terragrunt_config(
    find_in_parent_folders("root.hcl")
  )
}

inputs = {
  project_id = local.root.locals.global.project_id
  region     = local.root.locals.global.region
}
