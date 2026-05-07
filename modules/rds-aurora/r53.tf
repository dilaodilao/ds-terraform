variable "zone_id" {
  description = "r53 zone id"
  type        = string
}

variable "rds_dns_ro_name" {
  description = "name of dns record for rds ro cluster"
  type        = string
  
}

variable "rds_dns_rw_name" {
  description = "name of dns record for rds rw cluster"
  type        = string
  
}



resource "aws_route53_record" "Cluster_RW" {

  zone_id = var.zone_id
  name    = var.rds_dns_rw_name
  type    = "CNAME"
  ttl     = 300
  records = [ aws_rds_cluster.this[0].endpoint ]

}

resource "aws_route53_record" "Cluster_RO" {

  zone_id = var.zone_id
  name    = var.rds_dns_ro_name
  type    = "CNAME"
  ttl     = 300
  records = [ aws_rds_cluster.this[0].reader_endpoint ]

}

