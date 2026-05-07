# This is all you need for Same Account / Same Region
resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  auto_accept   = true

  tags = { Name = var.name }
}



resource "aws_route" "requester_to_accepter-public" {
  count                     = length(var.requester_route_table_ids_public)
  route_table_id            = var.requester_route_table_ids_public[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "requester_to_accepter-private" {
  count                     = length(var.requester_route_table_ids_private)
  route_table_id            = var.requester_route_table_ids_private[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}



resource "aws_route" "accepter_to_requester-public" {
  count                     = length(var.accepter_route_table_ids_public)
  route_table_id            = var.accepter_route_table_ids_public[count.index]
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "accepter_to_requester-private" {
  count                     = length(var.accepter_route_table_ids_private)
  route_table_id            = var.accepter_route_table_ids_private[count.index]
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
