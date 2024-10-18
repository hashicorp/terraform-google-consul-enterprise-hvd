# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0



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


