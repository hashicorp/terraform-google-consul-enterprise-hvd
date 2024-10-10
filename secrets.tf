# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "google_secret_manager_secret" "management_token" {
  secret_id = "${var.application_prefix}-consul-management-token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "snapshot_token" {
  secret_id = "${var.application_prefix}-consul-snapshot-token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "agent_token" {
  secret_id = "${var.application_prefix}-consul-agent-token"

  replication {
    auto {}
  }
}
