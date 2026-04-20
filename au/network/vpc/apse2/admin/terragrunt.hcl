terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=${include.root.locals.terraform_module_versions.vpc}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true

}

#easy reading of variables
locals {
  cidr_block  = include.root.locals.def.cidr[include.root.locals.def.env][include.root.locals.def.region][basename(get_terragrunt_dir())]
  region      = include.root.locals.def.region
  rgn         = include.root.locals.def.rgn
  env         = include.root.locals.def.env
  name        = basename(get_terragrunt_dir())
  azs         = include.root.locals.def.azs[include.root.locals.def.rgn]
}

inputs = {
  
  name = "ds-${local.region}-${local.name}-${local.env}"
  cidr = local.cidr_block

  azs = local.azs
  private_subnets = [for i in range(length(local.azs)) : cidrsubnet(local.cidr_block, 8, i)]
  public_subnets  = [for i in range(length(local.azs)) : cidrsubnet(local.cidr_block, 8, i+100)]
  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway = false


#  manage_default_network_acl = true
#  default_network_acl_name   = local.name
#
#  default_network_acl_ingress = [
#    # TIER 1: HARD DENIES (1 - 9999)
#    {
#      rule_no    = 100
#      action     = "deny"
#      from_port  = 22
#      to_port    = 22
#      protocol   = "tcp"
#      cidr_block = "0.0.0.0/0"
#    },
#    {
#      rule_no    = 200
#      action     = "deny"
#      from_port  = 3389
#      to_port    = 3389
#      protocol   = "tcp"
#      cidr_block = "0.0.0.0/0"
#    },
#    {
#      rule_no    = 300
#      action     = "deny"
#      from_port  = 23
#      to_port    = 23
#      protocol   = "tcp"
#      cidr_block = "0.0.0.0/0"
#    },
#    {
#      rule_no    = 400
#      action     = "deny"
#      from_port  = 445
#      to_port    = 445
#      protocol   = "tcp"
#      cidr_block = "0.0.0.0/0"
#    },
#
#    # TIER 2: ALLOWS (20000+)
#    {
#      rule_no    = 20000
#      action     = "allow"
#      from_port  = 80
#      to_port    = 443
#      protocol   = "tcp"
#      cidr_block = "0.0.0.0/0"
#    },
#    {
#      rule_no    = 20100
#      action     = "allow"
#      from_port  = 0
#      to_port    = 0
#      protocol   = "-1"
#      cidr_block = local.cidr_block
#    },
#    {
#      rule_no    = 20200
#      action     = "allow"
#      from_port  = 1024
#      to_port    = 65535
#      protocol   = "tcp"
#      cidr_block = "0.0.0.0/0"
#    }
#  ]
#
#  # OUTBOUND RULES
#  default_network_acl_egress = [
#    {
#      rule_no    = 100
#      action     = "allow"
#      from_port  = 0
#      to_port    = 0
#      protocol   = "-1"
#      cidr_block = "0.0.0.0/0"
#    }
#  ]
#



}


