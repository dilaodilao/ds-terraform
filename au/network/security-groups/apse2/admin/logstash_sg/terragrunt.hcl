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
  vpc_id      = dependency.admin-vpc.outputs.vpc_id
  description = "Security group for Logstash"
  tags        = merge( include.root.locals.default_tags, local.additional_tags )


  ingress_with_cidr_blocks = [
    {
        from_port = 22,
        to_port = 22,
        protocol = "tcp",
        description = "Imported rule",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 5044,
        to_port = 5044,
        protocol = "tcp",
        description = "LogStash",
        cidr_blocks = dependency.admin-vpc.outputs.vpc_id
    },
    {
        from_port = 5044,
        to_port = 5044,
        protocol = "tcp",
        description = "LogStash",
        cidr_blocks = dependency.application-vpc.outputs.vpc_id
    },
    {
        from_port = 2376,
        to_port = 2376,
        protocol = "tcp",
        description = "Imported rule",
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
