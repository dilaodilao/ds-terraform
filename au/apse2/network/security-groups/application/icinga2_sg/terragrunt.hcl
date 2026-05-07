terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=${include.root.locals.terraform_module_versions.security_group}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

# easy reading of variables
locals {
  region     = include.root.locals.def.region
  rgn        = include.root.locals.def.rgn
  env        = include.root.locals.def.env
  name       = basename(get_terragrunt_dir())
  azs        = include.root.locals.def.azs[include.root.locals.def.rgn]

  additional_tags = {}
}

dependency "admin-vpc" {
  config_path = "../../../vpc/admin"
}

dependency "application-vpc" {
  config_path = "../../../vpc/application"
}

dependency "video-vpc" {
  config_path = "../../../vpc/video"
}

inputs = {
  name        = local.name
  vpc_id      = dependency.application-vpc.outputs.vpc_id
  description = "Security Group for Icinga2"
  tags        = merge( include.root.locals.default_tags, local.additional_tags )


  ingress_with_cidr_blocks = [
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "icinga2",
        cidr_blocks = dependency.application-vpc.outputs.vpc_cidr_block
    },
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "icinga2",
        cidr_blocks = dependency.video-vpc.outputs.vpc_cidr_block
    },
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "icinga2",
        cidr_blocks = dependency.admin-vpc.outputs.vpc_cidr_block
    }
]

  egress_with_cidr_blocks = [
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "All protocols",
        cidr_blocks = "0.0.0.0/0"
    }
]
}
