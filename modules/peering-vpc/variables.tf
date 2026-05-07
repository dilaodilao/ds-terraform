variable "requester_vpc_id" {
  description = "The ID of the VPC sending the peering request"
  type        = string
}

variable "requester_vpc_cidr" {
  description = "The CIDR block of the requester VPC"
  type        = string
}

variable "requester_route_table_ids_public" {
  description = "List of route table IDs in the requester VPC that need routes to the accepter"
  type        = list(string)
}

variable "requester_route_table_ids_private" {
  description = "List of route table IDs in the requester VPC that need routes to the accepter"
  type        = list(string)
}

variable "accepter_vpc_id" {
  description = "The ID of the VPC accepting the peering request"
  type        = string
}

variable "accepter_vpc_cidr" {
  description = "The CIDR block of the accepter VPC"
  type        = string
}

variable "accepter_route_table_ids_public" {
  description = "List of route table IDs in the accepter VPC that need routes to the requester"
  type        = list(string)
}

variable "accepter_route_table_ids_private" {
  description = "List of route table IDs in the accepter VPC that need routes to the requester"
  type        = list(string)
}

variable "name" {
  description = "tag name used for peer connection"
  type        = string
}
