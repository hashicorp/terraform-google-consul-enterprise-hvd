# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  consul_metadata_template = fileexists("${path.cwd}/templates/${var.consul_metadata_template}") ? "${path.cwd}/templates/${var.consul_metadata_template}" : "${path.module}/templates/${var.consul_metadata_template}"
  consul_user_data_template_vars = {
    # system paths and settings
    application_prefix         = var.application_prefix
    systemd_dir                = var.systemd_dir,
    consul_dir_bin             = var.consul_dir_bin,
    consul_dir_config          = var.consul_dir_config,
    consul_snapshot_dir_config = var.consul_snapshot_dir_config
    consul_dir_home            = var.consul_dir_home,
    consul_dir_logs            = var.consul_dir_logs,
    consul_user_name           = var.consul_user_name,
    consul_group_name          = var.consul_group_name,

    # installation secrets
    consul_license_sm_secret_name       = var.consul_license_sm_secret_name
    consul_gossip_key_sm_secret_name    = var.consul_gossip_key_sm_secret_name
    consul_tls_cert_sm_secret_name      = var.consul_tls_cert_sm_secret_name
    consul_tls_privkey_sm_secret_name   = var.consul_tls_privkey_sm_secret_name
    consul_tls_ca_bundle_sm_secret_name = var.consul_tls_ca_cert_sm_secret_name,

    #Consul settings
    consul_version = var.consul_install_version,
    #consul_install_url     = format("https://releases.hashicorp.com/consul/%s/consul_%s_linux_amd64.zip", var.consul_install_version, var.consul_install_version),
    consul_fqdn            = var.consul_fqdn == null ? "" : var.consul_fqdn,
    consul_datacenter      = var.consul_datacenter
    auto_join_tag_value    = var.auto_join_tag == null ? var.tags[0] : var.auto_join_tag[0]
    auto_join_zone_pattern = "${var.region}-[[:alpha:]]{1}"
    consul_nodes           = var.consul_nodes
    snapshot_agent         = var.snapshot_agent
  }
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
resource "google_compute_instance_template" "consul" {
  name_prefix = format("%s-instance-template-", var.application_prefix)
  project     = var.project_id

  machine_type = var.machine_type

  tags   = concat(["consul-backend"], var.tags)
  labels = var.common_labels

  disk {
    source_image = var.packer_image == null ? format("%s/%s", var.compute_image_project, var.compute_image_family) : var.packer_image
    auto_delete  = true
    boot         = true
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnetwork.self_link
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [true] : []
      content {}
    }
  }

  metadata = var.metadata

  metadata_startup_script = templatefile(local.consul_metadata_template, local.consul_user_data_template_vars)

  service_account {
    email  = google_service_account.consul_sa.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "consul" {
  name    = "${var.application_prefix}-consul-ig-mgr"
  project = var.project_id

  base_instance_name = "${var.application_prefix}-consul-vm"
  #distribution_policy_zones = data.google_compute_zones.available.names
  #this change limits the serversprawl to 3 zones ensuring voters and none voters after first 3 instances
  distribution_policy_zones = slice(data.google_compute_zones.available.names, 0, 3)
  target_size               = var.consul_nodes
  region                    = var.region

  version {
    name              = google_compute_instance_template.consul.name
    instance_template = google_compute_instance_template.consul.self_link
  }

  update_policy {
    type = "OPPORTUNISTIC"
    #type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(data.google_compute_zones.available.names)
    max_unavailable_fixed        = 0
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "auto_healing_policies" {
    for_each = var.enable_auto_healing == true ? [true] : []
    content {
      health_check      = google_compute_health_check.consul_auto_healing[0].self_link
      initial_delay_sec = var.initial_auto_healing_delay
    }
  }

}


resource "google_compute_health_check" "consul_auto_healing" {
  count = var.enable_auto_healing == true ? 1 : 0

  name    = format("%s-autohealing-health-check", var.application_prefix)
  project = var.project_id

  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_timeout

  https_health_check {
    port               = 8501
    port_specification = "USE_FIXED_PORT"

    request_path = "/v1/status/leader"
  }

  log_config {
    enable = true
  }
}
