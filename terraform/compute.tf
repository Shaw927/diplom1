locals {
  # Имена
  web_instance_name   = "${var.vpc_name}-web"
  bastion_instance_name = "${var.vpc_name}-bastion"
  prometheus_instance_name = "${var.vpc_name}-prometheus"
  grafana_instance_name = "${var.vpc_name}-grafana"
  elasticsearch_instance_name = "${var.vpc_name}-elasticsearch"
  kibana_instance_name      = "${var.vpc_name}-kibana"

  # Web sites locals
  web_cores   = 2
  web_memory  = 2

  # Bastion locals
  bastion_cores  = 2
  bastion_memory = 2

  # Prometheus locals
  prometheus_cores = 2
  prometheus_memory = 2

  # Grafana locals
  grafana_cores = 2
  grafana_memory = 2

  # Elasticsearch locals
  elasticsearch_cores  = 4
  elasticsearch_memory = 4

  # Kibana locals
  kibana_cores  = 2
  kibana_memory = 2

  # Общие переменные
  platform_id       = "standard-v3"
  ubuntu24_image_id = "fd8kgdpgaocah5der4u2"
}

### Bastion main ###

resource "yandex_compute_instance" "bastion" {
  name        = local.bastion_instance_name
  platform_id = local.platform_id
  zone        = var.default_zone

  resources {
    cores  = local.bastion_cores
    memory = local.bastion_memory
  }

  boot_disk {
    initialize_params {
      image_id = local.ubuntu24_image_id
      size     = 20 # GB
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public["public-a"].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

### Web ###

resource "yandex_compute_instance" "web" {
  for_each = {
    "a" = {
      name_suffix = "a"
      subnet_id   = yandex_vpc_subnet.private["web-private-a"].id
      zone        = "ru-central1-a"
    }
    "b" = {
      name_suffix = "b"
      subnet_id   = yandex_vpc_subnet.private["web-private-b"].id
      zone        = "ru-central1-b"
    }
  }

  name        = "${local.web_instance_name}-${each.value.name_suffix}"
  platform_id = local.platform_id
  zone        = each.value.zone

  resources {
    cores  = local.web_cores
    memory = local.web_memory
  }

  boot_disk {
    initialize_params {
      image_id = local.ubuntu24_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = each.value.subnet_id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

### Prometheus ###

resource "yandex_compute_instance" "prometheus" {
  name        = local.prometheus_instance_name
  platform_id = local.platform_id
  zone        = var.default_zone

  resources {
    cores  = local.prometheus_cores
    memory = local.prometheus_memory
  }

  boot_disk {
    initialize_params {
      image_id = local.ubuntu24_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public["public-a"].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.prometheus.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

### Grafana ###

resource "yandex_compute_instance" "grafana" {
  name        = local.grafana_instance_name
  platform_id = local.platform_id
  zone        = var.default_zone

  resources {
    cores  = local.grafana_cores
    memory = local.grafana_memory
  }

  boot_disk {
    initialize_params {
      image_id = local.ubuntu24_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public["public-a"].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.grafana.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

### Elasticsearch ###

resource "yandex_compute_instance" "elasticsearch" {
  name        = local.elasticsearch_instance_name
  platform_id = local.platform_id
  zone        = var.default_zone

  resources {
    cores  = local.elasticsearch_cores
    memory = local.elasticsearch_memory
  }

  boot_disk {
    initialize_params {
      image_id = local.ubuntu24_image_id
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private["web-private-a"].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elasticsearch.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

### Kibana ###

resource "yandex_compute_instance" "kibana" {
  name        = local.kibana_instance_name
  platform_id = local.platform_id
  zone        = var.default_zone

  resources {
    cores  = local.kibana_cores
    memory = local.kibana_memory
  }

  boot_disk {
    initialize_params {
      image_id = local.ubuntu24_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public["public-a"].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
