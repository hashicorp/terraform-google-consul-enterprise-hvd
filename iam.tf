# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Service Account
#------------------------------------------------------------------------------
resource "google_service_account" "consul_sa" {
  account_id   = format("%s-service-account", var.application_prefix)
  display_name = "HashiCorp Consul service account"
  project      = var.project_id
}

resource "google_project_iam_member" "consul_iam" {
  for_each = toset(var.google_service_account_iam_roles)

  project = var.project_id
  role    = each.value
  member  = google_service_account.consul_sa.member
}

resource "google_secret_manager_secret_iam_member" "instance_read" {
  for_each  = local.all_secrets
  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.consul_sa.member
}

resource "google_secret_manager_secret_iam_member" "instance_write" {
  for_each  = local.secrets_rw
  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretVersionAdder"
  member    = google_service_account.consul_sa.member
}

resource "google_storage_bucket_iam_member" "snapshot_storage_rw" {
  count  = var.snapshot_agent.grant_iam_roles ? 1 : 0
  bucket = var.snapshot_agent.storage_bucket_name
  role   = "roles/storage.objectUser"
  member = google_service_account.consul_sa.member
}

locals {
  secrets_ro = toset([
    var.consul_license_sm_secret_name,
    var.consul_tls_cert_sm_secret_name,
    var.consul_tls_privkey_sm_secret_name,
    var.consul_tls_ca_cert_sm_secret_name,
    var.consul_gossip_key_sm_secret_name
  ])
  secrets_rw = toset([
    google_secret_manager_secret.management_token.secret_id,
    google_secret_manager_secret.snapshot_token.secret_id,
    google_secret_manager_secret.agent_token.secret_id
  ])
  all_secrets = toset(setunion(local.secrets_ro, local.secrets_rw))
}
