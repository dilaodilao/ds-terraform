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

  ips        = [
    "72.183.145.213/32",
    "136.49.7.73/32",
    "44.208.156.241/32",
    "34.202.15.239/32",
    "34.206.212.201/32",
    "44.199.49.168/32",
    "34.212.50.86/32",
    "172.127.49.214/32"
  ]

  ips_csv = join( ",", local.ips )
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
  vpc_id      = dependency.admin-vpc.outputs.vpc_id
  description = "Security Group for Load Balancer RANCHER"
  tags        = merge( include.root.locals.default_tags, local.additional_tags )

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP Access"
      cidr_blocks = local.ips_csv
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS Access"
      cidr_blocks = local.ips_csv
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
