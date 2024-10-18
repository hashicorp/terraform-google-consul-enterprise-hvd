# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "google_storage_bucket" "consul_snapshots" {
  name                        = var.snapshot_bucket_name
  location                    = var.bucket_location
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy               = var.force_destroy
}

module "consul-server" {
  source     = "../../"
  project_id = var.project_id

  consul_tls_cert_sm_secret_name    = var.consul_tls_cert_secret_id
  consul_tls_privkey_sm_secret_name = var.consul_tls_privkey_secret_id
  consul_tls_ca_cert_sm_secret_name = var.consul_tls_ca_cert_secret_id
  consul_license_sm_secret_name     = var.consul_license_secret_id
  consul_gossip_key_sm_secret_name  = var.consul_gossip_key_secret_id

  network    = var.vpc_name
  subnetwork = var.subnet_name

  snapshot_agent = {
    enabled             = var.snapshot_agent_enabled
    storage_bucket_name = google_storage_bucket.consul_snapshots.name
    grant_iam_roles     = var.snapshot_agent_grant_iam_roles
  }
}
