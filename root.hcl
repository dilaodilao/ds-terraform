# Enforce the Terragrunt version
terragrunt_version_constraint = local.binary_versions.terragrunt

# Enforce the OpenTofu / Terraform version
terraform_binary = local.binary_versions.terraform_binary
terraform_version_constraint = local.binary_versions.terraform





locals {

  def = merge(
  
    { workz = false},
    yamldecode(file(find_in_parent_folders("cidr.yml"))),
    yamldecode(file(find_in_parent_folders("env.yml"))),
    yamldecode(file(find_in_parent_folders("region.yml"))),
    yamldecode(file(find_in_parent_folders("subnets.yml"))),

  )

  default_tags = {
    environment = local.def.env
    managed_by = "OpenTofu"
    team = "devops"
  }



  terraform_module_versions = {
    s3        = "5.12.0"
    vpc       = "5.1.0"
    dynamodb  = "5.5.0"
    security_group  = "5.3.1"
    rds-aurora = "10.2.0"
    route53             = "6.4.0" 
  } 


  binary_versions = {
    terragrunt = "= 0.87.4"
    terraform = "= 1.11.6"
    terraform_binary = "tofu"
    aws_provider = "~> 6.0"
  } 


}




generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = "${local.binary_versions.terraform}"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${local.binary_versions.aws_provider}"
    }
  }
}
EOF
}


generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "${local.def.region}"
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
    bucket  = "${local.def.env}-tofu-state-bucket-${local.def.acct_num}-${local.def.region}"
    acl     = "bucket-owner-full-control"

    key = "${path_relative_to_include()}/terraform.json"
    region         = "${local.def.region}"
    encrypt        = true
    dynamodb_table = "${local.def.env}-tofu-lock-table"

  }
}
