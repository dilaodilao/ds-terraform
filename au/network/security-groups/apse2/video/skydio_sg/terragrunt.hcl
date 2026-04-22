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
  name        = "skydio_sg"
  vpc_id      = "vpc-02cfba27738c5fb6b"
  description = "Security Group for skydio testing"

  ingress_with_cidr_blocks = [
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "kubernetes",
        cidr_blocks = "10.5.0.0/16"
    },
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "kubernetes",
        cidr_blocks = "10.4.0.0/16"
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
