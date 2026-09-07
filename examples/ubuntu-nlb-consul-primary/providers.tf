# Copyright IBM Corp. 2024, 2026
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.42.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

