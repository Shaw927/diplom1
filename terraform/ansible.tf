resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory/hosts.yml"

  content = templatefile("${path.module}/ansible_hosts.tpl", {
    bastion_ip   = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
    prometheus_ip = yandex_compute_instance.prometheus.network_interface[0].ip_address
    grafana_ip    = yandex_compute_instance.grafana.network_interface[0].ip_address
    elasticsearch_ip = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
    kibana_ip        = yandex_compute_instance.kibana.network_interface[0].ip_address
    web_ips      = { for k, inst in yandex_compute_instance.web : k => inst.network_interface[0].ip_address }
 })
}
