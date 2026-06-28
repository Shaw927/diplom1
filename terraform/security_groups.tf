locals {
  sg_bastion_name = "${var.vpc_name}-bastion"
  sg_web_name     = "${var.vpc_name}-web"
  sg_alb_name     = "${var.vpc_name}-alb"
  sg_prometheus_name = "${var.vpc_name}-prometheus"
  sg_grafana_name = "${var.vpc_name}-grafana"
  sg_elasticsearch_name = "${var.vpc_name}-elasticsearch"
  sg_kibana_name        = "${var.vpc_name}-kibana"
}

resource "yandex_vpc_security_group" "bastion" {
  name       = local.sg_bastion_name
  network_id = yandex_vpc_network.main.id
  folder_id  = var.folder_id

  # SSH из интернета на bastion
  ingress {
    protocol       = "TCP"
    description    = "SSH доступ к bastion из интернета"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Исходящий: bastion может ходить в любую сеть (включая интернет)
  egress {
    protocol       = "ANY"
    description    = "Исходящий трафик везде"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "yandex_vpc_security_group" "alb" {
  name       = local.sg_alb_name
  network_id = yandex_vpc_network.main.id
  folder_id  = var.folder_id

  ingress {
    protocol       = "TCP"
    description    = "HTTP от интернета на ALB"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "Healthchecks для ALB"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }

  egress {
    protocol       = "ANY"
    description    = "Исходящий трафик от ALB к backend'ам"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === Web Servers Security Group ===

resource "yandex_vpc_security_group" "web" {
  name       = local.sg_web_name
  network_id = yandex_vpc_network.main.id
  folder_id  = var.folder_id

  # HTTP от ALB
  ingress {
    protocol       = "TCP"
    description    = "HTTP от балансера на web"
    security_group_id = yandex_vpc_security_group.alb.id
    port           = 80
  }

  # SSH только от bastion
  ingress {
    protocol          = "TCP"
    description       = "SSH от bastion на web"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "Scrape from prometheus"
    security_group_id = yandex_vpc_security_group.prometheus.id
    port              = 9100
}

  ingress {
    protocol          = "TCP"
    description       = "Nginx log exporter from Prometheus"
    security_group_id = yandex_vpc_security_group.prometheus.id
    port              = 4040
  }

  # Исходящий: web-сервера могут ходить куда угодно (через NAT)
  egress {
    protocol       = "ANY"
    description    = "Исходящий трафик везде"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prometheus" {
  name       = local.sg_prometheus_name
  network_id = yandex_vpc_network.main.id
  folder_id  = var.folder_id

### for check targets ###
#  ingress {
#    protocol       = "TCP"
#    description    = "Prometheus ui"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#    port           = 9090
#  }

  ingress {
    protocol       = "TCP"
    description    = "For ansible"
    security_group_id = yandex_vpc_security_group.bastion.id
    port           = 22
  }

  egress {
    protocol       = "TCP"
    description    = "Scrape node_exporter on web"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    from_port      = 9100
    to_port        = 9100
  }

  egress {
    protocol       = "ANY"
    description    = "Other egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana" {
  name       = local.sg_grafana_name
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.main.id

#  ingress {
#    description    = "Grafana UI from all"
#    protocol       = "TCP"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#    port           = 3000
#  }

### задумка что нужно пробросить порт 3000 через бастион и вебка будет доступна, либо блок выше раскоментить ### 
  ingress {
    description       = "Grafana UI only from bastion"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 3000
  }

  ingress {
    description    = "Grafana ssh acceses"
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port           = "22"
  }

  egress {
    description    = "Any outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === Elasticsearch Security Group ===

resource "yandex_vpc_security_group" "elasticsearch" {
  name       = local.sg_elasticsearch_name
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.main.id

  ingress {
    description       = "SSH access from bastion"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  ingress {
    description       = "Logs from web servers via Filebeat"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.web.id
    port              = 9200
  }

  ingress {
    description       = "Kibana access to Elasticsearch"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.kibana.id
    port              = 9200
  }

  egress {
    description    = "Any outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === Kibana Security Group ===

resource "yandex_vpc_security_group" "kibana" {
  name       = local.sg_kibana_name
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.main.id

 # ingress {
 #   description    = "Kibana UI from all"
 #   protocol       = "TCP"
 #   v4_cidr_blocks = ["0.0.0.0/0"]
 #   port           = 5601
 # }

### То же самое что и у графаны ###
  ingress {
    description       = "Kibana UI from bastion"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 5601
  }

  ingress {
    description       = "SSH access from bastion"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  egress {
    description       = "Access from Kibana to Elasticsearch"
    protocol          = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Any outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
