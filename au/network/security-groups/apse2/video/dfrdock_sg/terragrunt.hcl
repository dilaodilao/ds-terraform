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
  name        = "dfrdock_sg"
  vpc_id      = "vpc-02cfba27738c5fb6b"
  description = "Security Group for dfrdock"

  ingress_with_cidr_blocks = [
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "dfrdock",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 9000,
        to_port = 9000,
        protocol = "tcp",
        description = "dfrdock",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "dfrdock internal",
        cidr_blocks = "10.5.0.0/16"
    },
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "dfrdock internal",
        cidr_blocks = "10.4.0.0/16"
    },
    {
        from_port = 60000,
        to_port = 60999,
        protocol = "udp",
        description = "dfrdock control",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 1337,
        to_port = 1337,
        protocol = "tcp",
        description = "dfrdock ssl",
        cidr_blocks = "0.0.0.0/0"
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
