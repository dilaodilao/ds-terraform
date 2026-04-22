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
}


dependency "admin-vpc" {
  config_path = "../../../../vpc/apse2/admin"
}



inputs = {
  name        = "admin_base_sg"
  vpc_id      = dependency.admin-vpc.outputs.vpc_id
  description = "Security group for all instances in admin vpc"

  ingress_with_cidr_blocks = []

  egress_with_cidr_blocks = [
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "All protocols",
        cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = include.root.locals.default_tags
}
