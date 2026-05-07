#variable & function explanations
/*
- basename(get_terragrunt_dir())
returns the name of the current working directory


- basename(dirname(get_terragrunt_dir()))
will return the directory above the current working directory
so if the path is ../apse2/admin---application/terragrunt.hcl
it will return apse2
*/





terraform {
  source = "tfr:///terraform-aws-modules/route53/aws?version=${include.root.locals.terraform_module_versions.route53}"
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

dependency "admin-vpc" {
  config_path = "../../vpc/admin"
}

dependency "application-vpc" {
  config_path = "../../vpc/application"
}

dependency "video-vpc" {
  config_path = "../../vpc/video"
}


inputs = {

  name = "PRIVATE-${local.env}"
  comment = "Private zone for ${upper(local.env)}"

  vpc = {
    admin = {
      vpc_id      = dependency.admin-vpc.outputs.vpc_id
      vpc_region  = local.region
    }
    application = {
      vpc_id      = dependency.application-vpc.outputs.vpc_id
      vpc_region  = local.region
    }
    video = {
      vpc_id      = dependency.video-vpc.outputs.vpc_id
      vpc_region  = local.region
    }
  }

  tags = merge( include.root.locals.default_tags, local.additional_tags )

}
