# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "snapshot_bucket_name" {
  description = "Name of the GCS bucket for Consul snapshots"
  type        = string
}

variable "bucket_location" {
  description = "Location of the GCS bucket"
  type        = string
  default     = "US"
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket deletion when the bucket contains objects"
  type        = bool
  default     = false
}

variable "snapshot_agent_enabled" {
  description = "Enable Consul snapshot agent"
  type        = bool
  default     = true
}

variable "snapshot_agent_grant_iam_roles" {
  description = "Automatically assign roles/storage.objectUser to the Consul service account"
  type        = bool
  default     = true
}

# Variables for previously data-sourced values
variable "consul_tls_cert_secret_id" {
  description = "Secret ID for Consul TLS certificate"
  type        = string
}

variable "consul_tls_privkey_secret_id" {
  description = "Secret ID for Consul TLS private key"
  type        = string
}

variable "consul_tls_ca_cert_secret_id" {
  description = "Secret ID for Consul TLS CA certificate"
  type        = string
}

variable "consul_license_secret_id" {
  description = "Secret ID for Consul license"
  type        = string
}

variable "consul_gossip_key_secret_id" {
  description = "Secret ID for Consul gossip key"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}
