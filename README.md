# Consul Enterprise HVD on GCP GCE

Terraform module aligned with HashiCorp Validated Designs (HVD) to deploy Consul Enterprise on Google Cloud Platform (GCP) using Compute Engine instances.

## Prerequisites

This module requires the following resources to already be deployed to a GCP project:

- A VPC with a subnet in a region with 3+ zones
- GCP Secret Manager secrets with the following contents:
  - Consul server agent certificate, PEM formatted and base64-encoded
  - Consul server agent private key, PEM formatted and base64-encoded
  - Root certificate of the agent's signing authority, PEM formatted and base64-encoded
  - Consul gossip encryption key
- (Optional) A GCS bucket for backup snapshot storage

## Examples

The `examples/ubuntu-nlb-consul-primary` directory contains a reference implementation of a root-level module sourcing this repository.

## TLS

Suitable TLS certificates may be generated using the Consul CLI. See the [Consul TLS](https://developer.hashicorp.com/consul/commands/tls) page in the HashiCorp Developer Portal for more information.

The TLS certificate and private key data is expected to be provided via GCP Secret Manager secrets which contain PEM format x.509 certificates, further base64-encoded to eliminate newlines and special characters.

## Adding a Consul license

The Consul Enterprise license format is already suitable for storage in GCP Secret Manager and should be added without modification.

## ACL system

The ACL system will be automatically bootstrapped and configured with sane default policies for anonymous users, agent registration, and the snapshot agent.

ACL tokens are generated for the above policies, as well as the initial management token, and all are stored back to GCP Secret Manager for retrieval by the operator.

## Gossip encryption

A Consul gossip encryption key may be generated using the [consul keygen command](https://developer.hashicorp.com/consul/commands/keygen). This command outputs the key material already base64 encoded, and may be added directly to Secret Manager without modification.

## Module support

This open source software is maintained by the HashiCorp Technical Field Organization, independently of our enterprise products. While our Support Engineering team provides dedicated support for our enterprise offerings, this open source software is not included.

- For help using this open source software, please engage your account team.
- To report bugs/issues with this open source software, please open them directly against this code repository using the GitHub issues feature.

Please note that there is no official Service Level Agreement (SLA) for support of this software as a HashiCorp customer. This software falls under the definition of Community Software/Versions in your Agreement. We appreciate your understanding and collaboration in improving our open source projects.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 5.33 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_consul_health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_dns_tcp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_dns_udp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_gossip_tcp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_gossip_udp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_grpc_tls](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_rpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.consul_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_health_check.consul_auto_healing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_template.consul](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_backend_service.consul_bs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.consul_hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_region_instance_group_manager.consul](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_project_iam_member.consul_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.agent_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.management_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.snapshot_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.instance_read](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.instance_write](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.consul_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket_iam_member.snapshot_storage_rw](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_netblock_ip_ranges.legacy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |
| [google_netblock_ip_ranges.new](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_consul_gossip_key_sm_secret_name"></a> [consul\_gossip\_key\_sm\_secret\_name](#input\_consul\_gossip\_key\_sm\_secret\_name) | Name of Secret Manager secret containing Consul gossip encryption key. | `string` | n/a | yes |
| <a name="input_consul_license_sm_secret_name"></a> [consul\_license\_sm\_secret\_name](#input\_consul\_license\_sm\_secret\_name) | Name of Secret Manager secret containing Consul license. | `string` | n/a | yes |
| <a name="input_consul_tls_ca_cert_sm_secret_name"></a> [consul\_tls\_ca\_cert\_sm\_secret\_name](#input\_consul\_tls\_ca\_cert\_sm\_secret\_name) | Name of Secret Manager containing Consul TLS CA certificate. | `string` | n/a | yes |
| <a name="input_consul_tls_cert_sm_secret_name"></a> [consul\_tls\_cert\_sm\_secret\_name](#input\_consul\_tls\_cert\_sm\_secret\_name) | Name of Secret Manager containing Consul TLS certificate. | `string` | n/a | yes |
| <a name="input_consul_tls_privkey_sm_secret_name"></a> [consul\_tls\_privkey\_sm\_secret\_name](#input\_consul\_tls\_privkey\_sm\_secret\_name) | Name of Secret Manager containing Consul TLS private key. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (required) The project ID to host the cluster in (required) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (optional) The region to host the cluster in | `string` | n/a | yes |
| <a name="input_application_prefix"></a> [application\_prefix](#input\_application\_prefix) | (optional) The prefix to give to cloud entities | `string` | `"consul"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Whether instances should be assigned a public address. If false, they must be provisioned in a subnet with Cloud NAT deployed. | `bool` | `false` | no |
| <a name="input_auto_join_tag"></a> [auto\_join\_tag](#input\_auto\_join\_tag) | (optional) A list of a tag which will be used by Consul to join other nodes to the cluster. If left blank, the module will use the first entry in `tags` | `list(string)` | `null` | no |
| <a name="input_cidr_ingress_agent_allow"></a> [cidr\_ingress\_agent\_allow](#input\_cidr\_ingress\_agent\_allow) | CIDR ranges to allow agent traffic (gossip, Consul RPC) inbound to Consul instance(s). Automatically includes the local subnet. | `list(string)` | `[]` | no |
| <a name="input_cidr_ingress_dns_allow"></a> [cidr\_ingress\_dns\_allow](#input\_cidr\_ingress\_dns\_allow) | CIDR ranges to allow DNS traffic inbound to Consul instance(s). Automatically includes the local subnet. | `list(string)` | `[]` | no |
| <a name="input_cidr_ingress_grpctls_allow"></a> [cidr\_ingress\_grpctls\_allow](#input\_cidr\_ingress\_grpctls\_allow) | CIDR ranges to allow gRPC-TLS (peering, dataplane) traffic inbound to Consul instance(s). Automatically includes the local subnet. | `list(string)` | `[]` | no |
| <a name="input_cidr_ingress_https_allow"></a> [cidr\_ingress\_https\_allow](#input\_cidr\_ingress\_https\_allow) | CIDR ranges to allow HTTPS traffic inbound to Consul instance(s). | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_cidr_ingress_ssh_allow"></a> [cidr\_ingress\_ssh\_allow](#input\_cidr\_ingress\_ssh\_allow) | CIDR ranges to allow SSH traffic inbound to Consul instance(s). | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | (optional) Common labels to apply to GCP resources. | `map(string)` | `{}` | no |
| <a name="input_compute_image_family"></a> [compute\_image\_family](#input\_compute\_image\_family) | (optional) The family name of the image, https://cloud.google.com/compute/docs/images/os-details,defaults to `Ubuntu` | `string` | `"ubuntu-2204-lts"` | no |
| <a name="input_compute_image_project"></a> [compute\_image\_project](#input\_compute\_image\_project) | (optional) The project name of the image, https://cloud.google.com/compute/docs/images/os-details, defaults to `Ubuntu` | `string` | `"ubuntu-os-cloud"` | no |
| <a name="input_consul_datacenter"></a> [consul\_datacenter](#input\_consul\_datacenter) | (optional) Consul datacenter name to configure | `string` | `"dc1"` | no |
| <a name="input_consul_dir_bin"></a> [consul\_dir\_bin](#input\_consul\_dir\_bin) | Path to install Consul Enterprise binary | `string` | `"/usr/local/bin"` | no |
| <a name="input_consul_dir_config"></a> [consul\_dir\_config](#input\_consul\_dir\_config) | Path to install Consul Enterprise configuration | `string` | `"/etc/consul.d"` | no |
| <a name="input_consul_dir_home"></a> [consul\_dir\_home](#input\_consul\_dir\_home) | Path to hold data, plugins and license directories | `string` | `"/opt/consul"` | no |
| <a name="input_consul_dir_logs"></a> [consul\_dir\_logs](#input\_consul\_dir\_logs) | Path to hold Consul file audit device logs | `string` | `"/var/log/consul"` | no |
| <a name="input_consul_fqdn"></a> [consul\_fqdn](#input\_consul\_fqdn) | (optional) TLS servername to use when trying to connect to the cluster with HTTPS | `string` | `null` | no |
| <a name="input_consul_group_name"></a> [consul\_group\_name](#input\_consul\_group\_name) | Name of group to own Consul files and processes | `string` | `"consul"` | no |
| <a name="input_consul_install_version"></a> [consul\_install\_version](#input\_consul\_install\_version) | (optional) The version of Consul to use | `string` | `"1.19.1+ent"` | no |
| <a name="input_consul_metadata_template"></a> [consul\_metadata\_template](#input\_consul\_metadata\_template) | (optional) Alternative template file to provide for instance template metadata script. place the file in your local `./templates folder` no path required | `string` | `"google_consul_metadata.sh.tpl"` | no |
| <a name="input_consul_nodes"></a> [consul\_nodes](#input\_consul\_nodes) | (optional) The number of nodes to create in the pool | `number` | `6` | no |
| <a name="input_consul_snapshot_dir_config"></a> [consul\_snapshot\_dir\_config](#input\_consul\_snapshot\_dir\_config) | Path to install Consul snapshot agent configuration | `string` | `"/etc/consul-snapshot.d"` | no |
| <a name="input_consul_user_name"></a> [consul\_user\_name](#input\_consul\_user\_name) | Name of system user to own Consul files and processes | `string` | `"consul"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | (optional) The disk size (GB) to use to create the disk | `number` | `100` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | (optional) The disk type to use to create the disk | `string` | `"pd-ssd"` | no |
| <a name="input_enable_auto_healing"></a> [enable\_auto\_healing](#input\_enable\_auto\_healing) | (optional) Enable auto-healing on the Instance Group | `bool` | `false` | no |
| <a name="input_enable_iap"></a> [enable\_iap](#input\_enable\_iap) | (Optional bool) Enable https://cloud.google.com/iap/docs/using-tcp-forwarding#console, defaults to `true`. | `bool` | `true` | no |
| <a name="input_google_service_account_iam_roles"></a> [google\_service\_account\_iam\_roles](#input\_google\_service\_account\_iam\_roles) | (optional) List of project-level IAM roles to give to the Consul service account | `list(string)` | <pre>[<br/>  "roles/compute.viewer"<br/>]</pre> | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | (optional) How often, in seconds, to send a health check | `number` | `30` | no |
| <a name="input_health_timeout"></a> [health\_timeout](#input\_health\_timeout) | (optional) How long, in seconds, to wait before claiming failure | `number` | `15` | no |
| <a name="input_initial_auto_healing_delay"></a> [initial\_auto\_healing\_delay](#input\_initial\_auto\_healing\_delay) | (optional) The time, in seconds, that the managed instance group waits before it applies autohealing policies | `number` | `1200` | no |
| <a name="input_load_balancing_scheme"></a> [load\_balancing\_scheme](#input\_load\_balancing\_scheme) | (optional) Type of load balancer to use (INTERNAL, EXTERNAL, or NONE) | `string` | `"INTERNAL"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | (optional) The machine type to use for the Consul nodes | `string` | `"e2-standard-2"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | (optional) Metadata to add to the Compute Instance template | `map(string)` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | (optional) The VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | (optional) The project that the VPC network lives in. Can be left blank if network is in the same project as provider | `string` | `null` | no |
| <a name="input_network_region"></a> [network\_region](#input\_network\_region) | (optional) The region that the VPC network lives in. Can be left blank if network is in the same region as provider | `string` | `null` | no |
| <a name="input_packer_image"></a> [packer\_image](#input\_packer\_image) | (optional) The packer image to use | `string` | `null` | no |
| <a name="input_snapshot_agent"></a> [snapshot\_agent](#input\_snapshot\_agent) | Manage configuration of the Consul snapshot agent | <pre>object({<br/>    enabled             = bool<br/>    storage_bucket_name = optional(string)<br/>    grant_iam_roles     = optional(bool, true)<br/>    interval            = optional(string, "30m")<br/>    retention           = optional(number, 336) # 1 week @ 30m interval<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "grant_iam_roles": false<br/>}</pre> | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | (optional) The subnet in the VPC network to host the cluster in | `string` | `"default"` | no |
| <a name="input_systemd_dir"></a> [systemd\_dir](#input\_systemd\_dir) | Path to systemd directory for unit files | `string` | `"/etc/systemd/system"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) A list containing tags to assign to all resources | `list(string)` | <pre>[<br/>  "consul"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consul_service_account"></a> [consul\_service\_account](#output\_consul\_service\_account) | Member-format ID of the Consul server service account. |
| <a name="output_loadbalancer_ip"></a> [loadbalancer\_ip](#output\_loadbalancer\_ip) | The external ip address of the forwarding rule. |
<!-- END_TF_DOCS -->
