

terraform {
  source = "tfr:///terraform-aws-modules/dynamodb-table/aws?version=4.0.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
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

  deletion_protection_enabled = false

}
