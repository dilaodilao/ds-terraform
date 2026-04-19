terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true

}

inputs = {
  
  name = "${include.root.locals.def.env}-ZZZZZZZZZZZZZZZZZZZZZZZZZ-${basename(get_terragrunt_dir())}"
  cidr = include.root.locals.def.cidr[include.root.locals.def.env][basename(get_terragrunt_dir())]

  azs = include.root.locals.def.azs[include.root.locals.def.rgn]
  private_subnets = [for i in range(length(include.root.locals.def.azs[include.root.locals.def.rgn])) : cidrsubnet(include.root.locals.def.cidr[include.root.locals.def.env][basename(get_terragrunt_dir())], 8, i)]
  public_subnets  = [for i in range(length(include.root.locals.def.azs[include.root.locals.def.rgn])) : cidrsubnet(include.root.locals.def.cidr[include.root.locals.def.env][basename(get_terragrunt_dir())], 8, i+100)]
  enable_nat_gateway = false
  enable_vpn_gateway = false

}   


