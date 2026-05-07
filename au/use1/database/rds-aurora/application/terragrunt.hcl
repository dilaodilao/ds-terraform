terraform {
#  source = "tfr:///terraform-aws-modules/rds-aurora/aws?version=${include.root.locals.terraform_module_versions.rds-aurora}"
  source = "${local.repo_root}/modules/rds-aurora"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true

}


dependency "vpc" {
  config_path = "../../../network/vpc/application"
}

dependency "r53" {
  config_path = "../../../network/r53/vpc_private_zone"
}



#easy reading of variables
locals {
  region      = include.root.locals.def.region
  rgn         = include.root.locals.def.rgn
  env         = include.root.locals.def.env
  name        = "application"

  additional_tags = { }

  repo_root = get_repo_root()

}

inputs = {

  name = "${local.name}-mysql8"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.10.3"
  master_username = "dronesense"

  instances = {
    1 = {
      auto_minor_version_upgrade = true
      instance_class = "db.t4g.medium"
      publicly_accessible = false
    }
    2 = {
      auto_minor_version_upgrade = true
      instance_class = "db.t4g.medium"
      identifier = "${local.name}-aaaaaaaa"
    }
  }

  vpc_id = dependency.vpc.outputs.vpc_id
  backup_retention_period = 7
  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
  apply_immediately = false
  skip_final_snapshot = true

  cluster_parameter_group_name = "default.aurora-mysql8.0"
  cluster_db_instance_parameter_group_name = "default:aurora-mysql-8-0"

  #DNS
  zone_id         = dependency.r53.outputs.id
  rds_dns_rw_name = "${local.name}-rw.rds"
  rds_dns_ro_name = "${local.name}-ro.rds"

  tags = merge( include.root.locals.default_tags, local.additional_tags )

}
