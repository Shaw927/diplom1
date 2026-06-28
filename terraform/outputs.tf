output "alb_external_ip" {
  value = yandex_alb_load_balancer.web_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "prometheus_public_ip" {
  value = yandex_compute_instance.prometheus.network_interface[0].nat_ip_address
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

output "elasticsearch_private_ip" {
  value = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
}

output "node_exporter_targets" {
  value = [
    for inst in yandex_compute_instance.web :
    "${inst.network_interface[0].ip_address}:9100"
  ]
}

output "web_private_ips" {
  value = {
    for k, inst in yandex_compute_instance.web :
    k => inst.network_interface[0].ip_address
  }
}
