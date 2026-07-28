# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

module "default" {
  source     = "../.."
  project_id = var.project_id
  region     = var.region

  #------------------------------------------------------------------------------
  # Common
  #------------------------------------------------------------------------------
  tags               = var.tags
  application_prefix = var.application_prefix

  #------------------------------------------------------------------------------
  # Secrets (prereqs)
  #------------------------------------------------------------------------------
  consul_tls_cert_sm_secret_name    = var.consul_tls_cert_sm_secret_name
  consul_tls_privkey_sm_secret_name = var.consul_tls_privkey_sm_secret_name
  consul_tls_ca_cert_sm_secret_name = var.consul_tls_ca_cert_sm_secret_name
  consul_license_sm_secret_name     = var.consul_license_sm_secret_name
  consul_gossip_key_sm_secret_name  = var.consul_gossip_key_sm_secret_name

  create_cloud_dns_record = var.create_cloud_dns_record
  cloud_dns_managed_zone  = var.cloud_dns_managed_zone

  #------------------------------------------------------------------------------
  # Consul Configuration
  #------------------------------------------------------------------------------
  consul_fqdn            = var.consul_fqdn
  consul_install_version = var.consul_install_version
  consul_datacenter      = var.consul_datacenter
  auto_join_tag          = var.auto_join_tag

  #------------------------------------------------------------------------------
  # Networking
  #------------------------------------------------------------------------------
  network    = var.network
  subnetwork = var.subnetwork

  #------------------------------------------------------------------------------
  # Compute
  #------------------------------------------------------------------------------
  consul_nodes               = var.consul_nodes
  compute_image_family       = var.compute_image_family
  compute_image_project      = var.compute_image_project
  packer_image               = var.packer_image
  disk_type                  = var.disk_type
  disk_size                  = var.disk_size
  machine_type               = var.machine_type
  common_labels              = var.common_labels
  enable_auto_healing        = var.enable_auto_healing
  initial_auto_healing_delay = var.initial_auto_healing_delay
  enable_iap                 = var.enable_iap
  assign_public_ip           = var.assign_public_ip

  #------------------------------------------------------------------------------
  # IAM
  #------------------------------------------------------------------------------
  google_service_account_iam_roles = var.google_service_account_iam_roles

  #------------------------------------------------------------------------------
  # Load Balancer
  #------------------------------------------------------------------------------
  load_balancing_scheme = var.load_balancing_scheme
  health_check_interval = var.health_check_interval
  health_timeout        = var.health_timeout

  #------------------------------------------------------------------------------
  # Snapshot Storage
  #------------------------------------------------------------------------------
  snapshot_agent = var.snapshot_agent
}
