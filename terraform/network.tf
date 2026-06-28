resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

resource "yandex_vpc_gateway" "nat" {
  name = "${var.vpc_name}-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private_rt" {
  name       = "${var.vpc_name}-private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "private" {
  for_each = { for subnet in var.private_subnets : subnet.name => subnet }
  name           = each.value.name
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_subnet" "public" {
  for_each = { for subnet in var.public_subnets : subnet.name => subnet }
  name           = each.value.name
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
}
