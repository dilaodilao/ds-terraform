locals {

  def = merge(
  
    { workz = false},
    yamldecode(file(find_in_parent_folders("cidr.yml"))),
    yamldecode(file(find_in_parent_folders("env.yml"))),
    yamldecode(file(find_in_parent_folders("subnets.yml"))),

  )

}



generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "us-east-1"
}

EOF
}


remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket  = "${local.def.env}-tofu-state-bucket-${local.def.acct_num}-us-east-1"
    acl     = "bucket-owner-full-control"

    key = "${path_relative_to_include()}/terraform.json"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "${local.def.env}-tofu-lock-table"

  }
}
