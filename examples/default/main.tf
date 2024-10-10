data "terraform_remote_state" "prereqs" {
  backend = "local"

  config = {
    path = "../consul-prereqs/terraform.tfstate"
  }
}

resource "google_storage_bucket" "consul_snapshots" {
  name                        = "<snapshot bucket name>"
  location                    = "US"
  uniform_bucket_level_access = true
  force_destroy               = true # For dev/test, allow bucket deletion while it contains objects
}

module "consul-server" {
  source     = "github.com/hasicorp-services/terraform-google-consul-vm"
  project_id = "1234567890"

  consul_tls_cert_sm_secret_name    = data.terraform_remote_state.prereqs.outputs.consul_tls_cert_secret_id
  consul_tls_privkey_sm_secret_name = data.terraform_remote_state.prereqs.outputs.consul_tls_privkey_secret_id
  consul_tls_ca_cert_sm_secret_name = data.terraform_remote_state.prereqs.outputs.consul_tls_ca_cert_secret_id
  consul_license_sm_secret_name     = data.terraform_remote_state.prereqs.outputs.consul_license_secret_id
  consul_gossip_key_sm_secret_name  = data.terraform_remote_state.prereqs.outputs.consul_gossip_key_secret_id

  network    = data.terraform_remote_state.prereqs.outputs.vpc_name
  subnetwork = data.terraform_remote_state.prereqs.outputs.subnet_name

  snapshot_agent = {
    enabled             = true
    storage_bucket_name = google_storage_bucket.consul_snapshots.name
    grant_iam_roles     = true # Automatically assign roles/storage.objectUser to the Consul service account
  }
}
