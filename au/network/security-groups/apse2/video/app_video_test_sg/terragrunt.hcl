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
  config_path = "../../../../vpc/apse2/admin"
}

dependency "application-vpc" {
  config_path = "../../../../vpc/apse2/application"
}

dependency "video-vpc" {
  config_path = "../../../../vpc/apse2/video"
}

inputs = {
  name        = local.name
  vpc_id      = dependency.video-vpc.outputs.vpc_id
  description = "Security Group for APP API"
  tags        = merge( include.root.locals.default_tags, local.additional_tags )


  ingress_with_cidr_blocks = [
    {
        from_port = 7088,
        to_port = 7088,
        protocol = "tcp",
        description = "admin port from api VPC",
        cidr_blocks = dependency.application-vpc.outputs.vpc_id
    },
    {
        from_port = 7088,
        to_port = 7088,
        protocol = "tcp",
        description = "Robert House",
        cidr_blocks = "72.183.151.250/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 20000,
        to_port = 25000,
        protocol = "udp",
        description = "ports for video",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
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
