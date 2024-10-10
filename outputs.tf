output "loadbalancer_ip" {
  description = "The external ip address of the forwarding rule."
  value       = [google_compute_forwarding_rule.consul_fr[*].ip_address]
}

output "consul_service_account" {
  description = "Member-format ID of the Consul server service account."
  value       = google_service_account.consul_sa.member
}