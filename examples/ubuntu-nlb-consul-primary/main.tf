# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

module "default" {
  source     = "../.."
  project_id = var.project_id
  region     = var.region

  consul_tls_cert_sm_secret_name    = var.consul_tls_cert_sm_secret_name
  consul_tls_privkey_sm_secret_name = var.consul_tls_privkey_sm_secret_name
  consul_tls_ca_cert_sm_secret_name = var.consul_tls_ca_cert_sm_secret_name
  consul_license_sm_secret_name     = var.consul_license_sm_secret_name
  consul_gossip_key_sm_secret_name  = var.consul_gossip_key_sm_secret_name

  network    = var.network
  subnetwork = var.subnetwork

  snapshot_agent = var.snapshot_agent
}
