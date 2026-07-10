# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

data "google_dns_managed_zone" "consul" {
  count = var.create_cloud_dns_record == true ? 1 : 0

  name = var.cloud_dns_managed_zone
}

resource "google_dns_record_set" "consul" {
  count = var.create_cloud_dns_record == true ? 1 : 0

  managed_zone = data.google_dns_managed_zone.consul[0].name
  name         = "${var.consul_fqdn}."
  type         = "A"
  ttl          = 60
  rrdatas      = [google_compute_forwarding_rule.consul_fr[0].ip_address]
}
