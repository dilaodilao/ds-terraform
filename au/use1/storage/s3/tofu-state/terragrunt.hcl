include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=${include.root.locals.terraform_module_versions.s3}"
}

locals {

  additional_tags = {
    Project = "ds-tofu"
    Purpose = "tofu-state-locking"
    aws_service = "state"
  }

}


inputs = {

  bucket        = "${include.root.locals.def.env}-tofu-state-bucket-${include.root.locals.def.acct_num}-${include.root.locals.def.region}"
  force_destroy = false

  versioning    = {
    enabled = true
  }
  server_side_encryption_configuration  = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge( include.root.locals.default_tags, local.additional_tags )

  


}

