include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/dynamodb-table/aws?version=${include.root.locals.terraform_module_versions.dynamodb}"
}

locals {

  additional_tags = {
    Project = "ds-tofu"
    Purpose = "tofu-state-locking"
    aws_service = "state"
  }

}





inputs = {
  name     = "${include.root.locals.def.env}-tofu-lock-table"
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"

  deletion_protection_enabled = true


  tags = merge( include.root.locals.default_tags, local.additional_tags )
}
