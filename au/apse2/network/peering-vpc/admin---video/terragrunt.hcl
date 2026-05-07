terraform {
  source = "../../../../../modules/peering-vpc"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true

}

#easy reading of variables
locals {
  region      = include.root.locals.def.region
  rgn         = include.root.locals.def.rgn
  env         = include.root.locals.def.env
  name        = basename(get_terragrunt_dir())

  additional_tags = { }
}

# basename(dirname(get_terragrunt_dir())) will return the directory above this
# so if the path is ../apse2/admin---application/terragrunt.hcl
# it will return apse2
dependency "vpc-requester" {
  config_path = "../../vpc/admin"
}

dependency "vpc-accepter" {
  config_path = "../../vpc/video"
}


inputs = {

  name = "ds-${local.name}"

  requester_vpc_id                  = dependency.vpc-requester.outputs.vpc_id
  accepter_vpc_id                   = dependency.vpc-accepter.outputs.vpc_id

  requester_vpc_cidr                = dependency.vpc-requester.outputs.vpc_cidr_block
  accepter_vpc_cidr                 = dependency.vpc-accepter.outputs.vpc_cidr_block

  requester_route_table_ids_public  = dependency.vpc-requester.outputs.public_route_table_ids
  requester_route_table_ids_private = dependency.vpc-requester.outputs.private_route_table_ids

  accepter_route_table_ids_public   = dependency.vpc-accepter.outputs.public_route_table_ids
  accepter_route_table_ids_private  = dependency.vpc-accepter.outputs.private_route_table_ids


  tags = merge( include.root.locals.default_tags, local.additional_tags )



}
