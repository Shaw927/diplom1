# === Target Group для web-серверов ===

resource "yandex_alb_target_group" "web_tg" {
  name      = "${var.vpc_name}-web-tg"
  folder_id = var.folder_id

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

# === Backend Group для web ===

resource "yandex_alb_backend_group" "web_bg" {
  name      = "${var.vpc_name}-web-bg"
  folder_id = var.folder_id

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]

    healthcheck {
      timeout  = "1s"
      interval = "3s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# === HTTP Router ===

resource "yandex_alb_http_router" "web_router" {
  name      = "${var.vpc_name}-http-router"
  folder_id = var.folder_id
}

resource "yandex_alb_virtual_host" "web_vhost" {
  name           = "${var.vpc_name}-vhost"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "web-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
      }
    }
  }
}

# === Application Load Balancer ===

resource "yandex_alb_load_balancer" "web_alb" {
  name      = "${var.vpc_name}-alb"
  folder_id = var.folder_id
  network_id = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public["public-a"].id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}
