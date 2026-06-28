locals {
  snapshot_disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web["a"].boot_disk[0].disk_id,
    yandex_compute_instance.web["b"].boot_disk[0].disk_id,
    yandex_compute_instance.prometheus.boot_disk[0].disk_id,
    yandex_compute_instance.grafana.boot_disk[0].disk_id,
    yandex_compute_instance.elasticsearch.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id
  ]
}

resource "yandex_compute_snapshot_schedule" "daily_all_vms" {
  name = "daily-all-vms-snapshots"

  schedule_policy {
    expression = "0 2 * * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "Daily automatic snapshots for diploma infrastructure"
    labels = {
      project = "diplom"
      type    = "auto"
    }
  }

  disk_ids = local.snapshot_disk_ids
}

