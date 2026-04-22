terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=${include.root.locals.terraform_module_versions.security_group}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

# easy reading of variables
locals {
  cidr_block = include.root.locals.def.cidr[include.root.locals.def.env][include.root.locals.def.region][basename(get_terragrunt_dir())]
  region     = include.root.locals.def.region
  rgn        = include.root.locals.def.rgn
  env        = include.root.locals.def.env
  name       = basename(get_terragrunt_dir())
  azs        = include.root.locals.def.azs[include.root.locals.def.rgn]
}

inputs = {
  name        = "lb_emqx_sg"
  vpc_id      = "vpc-02cfba27738c5fb6b"
  description = "Security Group for Load Balancer abacus"

  ingress_with_cidr_blocks = [
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "72.183.145.213/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "136.49.7.73/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "44.208.156.241/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "34.202.15.239/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "34.206.212.201/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "44.199.49.168/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "34.212.50.86/32"
    },
    {
        from_port = 80,
        to_port = 80,
        protocol = "tcp",
        description = "HTTP",
        cidr_blocks = "172.127.49.214/32"
    },
    {
        from_port = 8084,
        to_port = 8084,
        protocol = "tcp",
        description = "rancher",
        cidr_blocks = "0.0.0.0/0"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "72.183.145.213/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "136.49.7.73/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "44.208.156.241/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "34.202.15.239/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "34.206.212.201/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "44.199.49.168/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "34.212.50.86/32"
    },
    {
        from_port = 443,
        to_port = 443,
        protocol = "tcp",
        description = "HTTPS",
        cidr_blocks = "172.127.49.214/32"
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
