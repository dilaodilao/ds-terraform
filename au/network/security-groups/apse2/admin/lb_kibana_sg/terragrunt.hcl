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

  kibana_whitelist = [
    "72.183.151.250/32", "44.199.49.168/32", "34.212.50.86/32",
    "47.221.151.33/32", "98.59.3.215/32", "70.251.184.116/32",
    "72.133.87.81/32", "70.122.41.48/32", "69.153.17.189/32",
    "74.96.155.72/32", "24.55.35.121/32", "136.49.66.145/32",
    "97.113.217.213/32", "136.56.0.202/32", "131.93.101.188/32",
    "24.55.47.84/32", "107.77.220.112/32", "96.255.30.158/32",
    "18.221.202.115/32", "108.56.193.108/32", "47.134.8.81/32",
    "166.205.97.107/32", "12.75.74.101/32"
  ]
  
  kibana_whitelist_csv = join( ",", local.kibana_whitelist )

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
  description = "Security Group for Load Balancer kibana"
  tags        = merge( include.root.locals.default_tags, local.additional_tags )


  ingress_with_cidr_blocks = [
    # Bulk HTTP (80) Rules
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access for app users"
      cidr_blocks = local.kibana_whitelist_csv
    },
    # Bulk HTTPS (443) Rules
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access for app users"
      cidr_blocks = local.kibana_whitelist_csv
    },
    # Unique/Single Rules
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Special HTTPS source"
      cidr_blocks = "73.164.91.143/32"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 2376
      to_port     = 2376
      protocol    = "tcp"
      description = "Docker Daemon"
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
