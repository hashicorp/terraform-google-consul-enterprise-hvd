resource "google_compute_firewall" "allow_ssh" {
  name        = "${var.application_prefix}-consul-firewall-ssh-allow"
  description = "Allow SSH ingress to Consul instances from specified CIDR ranges."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [22]
  }
  source_ranges = var.cidr_ingress_ssh_allow
  target_tags   = ["consul-backend"]
}

resource "google_compute_firewall" "allow_iap" {
  count = var.enable_iap == true ? 1 : 0
  name  = "${var.application_prefix}-consul-firewall-iap-allow"

  description = "Allow https://cloud.google.com/iap/docs/using-tcp-forwarding#console traffic"
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [3389, 22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["consul-backend"]
}
resource "google_compute_firewall" "allow_https" {
  name = "${var.application_prefix}-consul-firewall-https-allow"

  description = "Allow HTTPS traffic ingress to Consul instances in ${data.google_compute_network.network.name} from specified CIDR ranges."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8501"]
  }

  source_ranges = var.cidr_ingress_https_allow
  target_tags   = ["consul-backend"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_gossip_tcp" {
  name = "${var.application_prefix}-consul-firewall-gossip-tcp-allow"

  description = "Allow gossip traffic between Consul instances in ${data.google_compute_network.network.name}."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8301-8302"]
  }

  source_ranges = local.agent_comm_allowed_cidrs
  target_tags   = ["consul-backend"]
}

resource "google_compute_firewall" "allow_gossip_udp" {
  name = "${var.application_prefix}-consul-firewall-gossip-udp-allow"

  description = "Allow gossip traffic between Consul instances in ${data.google_compute_network.network.name}."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "udp"
    ports    = ["8301-8302"]
  }

  source_ranges = local.agent_comm_allowed_cidrs
  target_tags   = ["consul-backend"]
}

resource "google_compute_firewall" "allow_rpc" {
  name = "${var.application_prefix}-consul-firewall-rpc-allow"

  description = "Allow RPC traffic between Consul instances in ${data.google_compute_network.network.name}."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8300"]
  }

  source_ranges = local.agent_comm_allowed_cidrs
  target_tags   = ["consul-backend"]
}

resource "google_compute_firewall" "allow_grpc_tls" {
  name = "${var.application_prefix}-consul-firewall-grpctls-allow"

  description = "Allow gRPC-TLS traffic into Consul instances in ${data.google_compute_network.network.name}."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8503"]
  }

  source_ranges = local.grpc_tls_allowed_cidrs
  target_tags   = ["consul-backend"]
}

resource "google_compute_firewall" "allow_dns_udp" {
  name = "${var.application_prefix}-consul-firewall-dns-udp-allow"

  description = "Allow DNS traffic into Consul instances in ${data.google_compute_network.network.name}."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "udp"
    ports    = ["8600"]
  }

  source_ranges = local.dns_allowed_cidrs
  target_tags   = ["consul-backend"]
}

resource "google_compute_firewall" "allow_dns_tcp" {
  name = "${var.application_prefix}-consul-firewall-dns-tcp-allow"

  description = "Allow DNS traffic into Consul instances in ${data.google_compute_network.network.name}."
  network     = data.google_compute_network.network.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8600"]
  }

  source_ranges = local.dns_allowed_cidrs
  target_tags   = ["consul-backend"]
}

locals {
  dns_allowed_cidrs        = concat([data.google_compute_subnetwork.subnetwork.ip_cidr_range], var.cidr_ingress_dns_allow)
  grpc_tls_allowed_cidrs   = concat([data.google_compute_subnetwork.subnetwork.ip_cidr_range], var.cidr_ingress_grpctls_allow)
  agent_comm_allowed_cidrs = concat([data.google_compute_subnetwork.subnetwork.ip_cidr_range], var.cidr_ingress_agent_allow)
}
