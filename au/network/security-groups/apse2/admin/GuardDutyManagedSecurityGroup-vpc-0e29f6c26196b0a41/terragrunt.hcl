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
  name        = "GuardDutyManagedSecurityGroup-vpc-0e29f6c26196b0a41"
  vpc_id      = "vpc-0e29f6c26196b0a41"
  description = "Associated with VPC-vpc-0e29f6c26196b0a41 and tagged as GuardDutyManaged"

  ingress_with_cidr_blocks = [
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "Imported rule",
        cidr_blocks = "0.0.0.0/0"
    }
]

  egress_with_cidr_blocks = []
}
