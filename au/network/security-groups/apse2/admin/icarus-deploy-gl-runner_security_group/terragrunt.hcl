terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=${include.root.locals.terraform_module_versions.security_group}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

# easy reading of variables
locals {
  cidr_block = include.root.locals.def.cidr[include.root.locals.def.env][include.root.locals.def.region][basename(get_terragrunt_dir())]
  region     = include.root.locals.def.region
  rgn        = include.root.locals.def.rgn
  env        = include.root.locals.def.env
  name       = basename(get_terragrunt_dir())
  azs        = include.root.locals.def.azs[include.root.locals.def.rgn]
}

inputs = {
  name        = "icarus-deploy-gl-runner_security_group"
  vpc_id      = "vpc-0e29f6c26196b0a41"
  description = "Security group for the docker runner ASG"

  ingress_with_cidr_blocks = [
    {
        from_port = 22,
        to_port = 22,
        protocol = "tcp",
        description = "Imported rule",
        cidr_blocks = "10.4.0.139/32"
    }
]

  egress_with_cidr_blocks = [
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "Imported rule",
        cidr_blocks = "0.0.0.0/0"
    }
]
}
