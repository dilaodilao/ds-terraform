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
  description = "Managed by Terraform"
  tags        = merge( include.root.locals.default_tags, local.additional_tags )


  ingress_with_cidr_blocks = [
    {
        from_port = 3306,
        to_port = 3306,
        protocol = "tcp",
        description = "Allow traffic on port 3306 from CIDR in DMZ",
        cidr_blocks = "172.20.0.0/16"
    },
    {
        from_port = 3306,
        to_port = 3306,
        protocol = "tcp",
        description = "Allow traffic on port 3306 from API-DEPLOY subnet",
        cidr_blocks = "10.5.2.0/24"
    },
    {
        from_port = 3306,
        to_port = 3306,
        protocol = "tcp",
        description = "TEST",
        cidr_blocks = "10.0.0.0/8"
    }
]

  egress_with_cidr_blocks = [
    {
        from_port = 0,
        to_port = 0,
        protocol = "all",
        description = "All egress",
        cidr_blocks = "0.0.0.0/0"
    }
]
}
