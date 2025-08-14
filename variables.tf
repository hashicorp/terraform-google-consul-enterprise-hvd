# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#-----------------------------------------------------------------------------------
# Common
#-----------------------------------------------------------------------------------
variable "project_id" {
  type        = string
  description = "(required) The project ID to host the cluster in (required)"
}

variable "region" {
  type        = string
  description = "(optional) The region to host the cluster in"
}

variable "tags" {
  type        = list(string)
  description = "(optional) A list containing tags to assign to all resources"
  default     = ["consul"]
}

variable "application_prefix" {
  type        = string
  description = "(optional) The prefix to give to cloud entities"
  default     = "consul"
}

#------------------------------------------------------------------------------
# prereqs
#------------------------------------------------------------------------------
variable "consul_license_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager secret containing Consul license."
}

variable "consul_tls_cert_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager containing Consul TLS certificate."
}

variable "consul_tls_privkey_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager containing Consul TLS private key."
}

variable "consul_tls_ca_cert_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager containing Consul TLS CA certificate."
}

variable "consul_gossip_key_sm_secret_name" {
  type        = string
  description = "Name of Secret Manager secret containing Consul gossip encryption key."
}

#------------------------------------------------------------------------------
# Consul configuration settings
#------------------------------------------------------------------------------
variable "consul_fqdn" {
  type        = string
  description = "(optional) TLS servername to use when trying to connect to the cluster with HTTPS"
  default     = null
}

variable "consul_install_version" {
  type        = string
  description = "(optional) The version of Consul to use"
  default     = "1.21.0+ent"
}

variable "consul_datacenter" {
  type        = string
  description = "(optional) Consul datacenter name to configure"
  default     = "dc1"
}

variable "auto_join_tag" {
  type        = list(string)
  description = "(optional) A list of a tag which will be used by Consul to join other nodes to the cluster. If left blank, the module will use the first entry in `tags`"
  default     = null
}

#------------------------------------------------------------------------------
# System paths and settings
#------------------------------------------------------------------------------
variable "consul_user_name" {
  type        = string
  description = "Name of system user to own Consul files and processes"
  default     = "consul"
}

variable "consul_group_name" {
  type        = string
  description = "Name of group to own Consul files and processes"
  default     = "consul"
}

variable "systemd_dir" {
  type        = string
  description = "Path to systemd directory for unit files"
  default     = "/etc/systemd/system"
}

variable "consul_dir_bin" {
  type        = string
  description = "Path to install Consul Enterprise binary"
  default     = "/usr/local/bin"
}

variable "consul_dir_config" {
  type        = string
  description = "Path to install Consul Enterprise configuration"
  default     = "/etc/consul.d"
}

variable "consul_dir_home" {
  type        = string
  description = "Path to hold data, plugins and license directories"
  default     = "/opt/consul"
}

variable "consul_dir_logs" {
  type        = string
  description = "Path to hold Consul file audit device logs"
  default     = "/var/log/consul"
}

variable "consul_snapshot_dir_config" {
  type        = string
  description = "Path to install Consul snapshot agent configuration"
  default     = "/etc/consul-snapshot.d"
}

#-----------------------------------------------------------------------------------
# Networking
#-----------------------------------------------------------------------------------
variable "network" {
  type        = string
  description = "(optional) The VPC network to host the cluster in"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "(optional) The subnet in the VPC network to host the cluster in"
  default     = "default"
}

variable "network_project_id" {
  type        = string
  description = "(optional) The project that the VPC network lives in. Can be left blank if network is in the same project as provider"
  default     = null
}

variable "network_region" {
  type        = string
  description = "(optional) The region that the VPC network lives in. Can be left blank if network is in the same region as provider"
  default     = null
}

variable "cidr_ingress_ssh_allow" {
  type        = list(string)
  description = "CIDR ranges to allow SSH traffic inbound to Consul instance(s)."
  default     = ["10.0.0.0/16"]
}

variable "cidr_ingress_https_allow" {
  type        = list(string)
  description = "CIDR ranges to allow HTTPS traffic inbound to Consul instance(s)."
  default     = ["0.0.0.0/0"]
}

variable "cidr_ingress_dns_allow" {
  type        = list(string)
  description = "CIDR ranges to allow DNS traffic inbound to Consul instance(s). Automatically includes the local subnet."
  default     = []
}

variable "cidr_ingress_grpctls_allow" {
  type        = list(string)
  description = "CIDR ranges to allow gRPC-TLS (peering, dataplane) traffic inbound to Consul instance(s). Automatically includes the local subnet."
  default     = []
}

variable "cidr_ingress_agent_allow" {
  type        = list(string)
  description = "CIDR ranges to allow agent traffic (gossip, Consul RPC) inbound to Consul instance(s). Automatically includes the local subnet."
  default     = []
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether instances should be assigned a public address. If false, they must be provisioned in a subnet with Cloud NAT deployed."
  default     = false
}

#-----------------------------------------------------------------------------------
# Compute
#-----------------------------------------------------------------------------------
variable "consul_nodes" {
  type        = number
  description = "(optional) The number of nodes to create in the pool"
  default     = 6
}

variable "consul_metadata_template" {
  type        = string
  description = "(optional) Alternative template file to provide for instance template metadata script. place the file in your local `./templates folder` no path required"
  default     = "google_consul_metadata.sh.tpl"
  validation {
    condition     = can(fileexists("${path.cwd}/templates/${var.consul_metadata_template}") || fileexists("${path.module}/templates/${var.consul_metadata_template}"))
    error_message = "File `${path.cwd}templates/${var.consul_metadata_template}` or `${path.module}/templates/${var.consul_metadata_template} not found or not readable"
  }
}

variable "compute_image_family" {
  type        = string
  description = "(optional) The family name of the image, https://cloud.google.com/compute/docs/images/os-details,defaults to `Ubuntu`"
  default     = "ubuntu-2204-lts"
}

variable "compute_image_project" {
  type        = string
  description = "(optional) The project name of the image, https://cloud.google.com/compute/docs/images/os-details, defaults to `Ubuntu`"
  default     = "ubuntu-os-cloud"
}

# Rename to vm_custom_image_name (or similar)
variable "packer_image" {
  type        = string
  description = "(optional) The packer image to use"
  default     = null
}

variable "disk_type" {
  type        = string
  description = "(optional) The disk type to use to create the disk"
  default     = "pd-ssd"

  validation {
    condition     = var.disk_type == "pd-ssd" || var.disk_type == "local-ssd" || var.disk_type == "pd-balanced" || var.disk_type == "pd-standard"
    error_message = "The value must be either pd-ssd, local-ssd, pd-balanced, pd-standard."
  }
}

variable "disk_size" {
  type        = number
  description = "(optional) The disk size (GB) to use to create the disk"
  default     = 100
}

variable "machine_type" {
  type        = string
  description = "(optional) The machine type to use for the Consul nodes"
  default     = "e2-standard-2"
}

variable "common_labels" {
  type        = map(string)
  description = "(optional) Common labels to apply to GCP resources."
  default     = {}
}

variable "metadata" {
  type        = map(string)
  description = "(optional) Metadata to add to the Compute Instance template"
  default     = null
}

variable "enable_auto_healing" {
  type        = bool
  description = "(optional) Enable auto-healing on the Instance Group"
  default     = false
}

variable "initial_auto_healing_delay" {
  type        = number
  description = "(optional) The time, in seconds, that the managed instance group waits before it applies autohealing policies"
  default     = 1200 #300

  validation {
    condition     = var.initial_auto_healing_delay >= 0 && var.initial_auto_healing_delay <= 3600
    error_message = "The value must be greater than or equal to 0 and less than or equal to 3600s."
  }
}

variable "enable_iap" {
  type        = bool
  default     = true
  description = "(Optional bool) Enable https://cloud.google.com/iap/docs/using-tcp-forwarding#console, defaults to `true`. "
}

#-----------------------------------------------------------------------------------
# IAM variables
#-----------------------------------------------------------------------------------
variable "google_service_account_iam_roles" {
  type        = list(string)
  description = "(optional) List of project-level IAM roles to give to the Consul service account"
  default = [
    "roles/compute.viewer"
  ]
}

#-----------------------------------------------------------------------------------
# Load Balancer variables
#-----------------------------------------------------------------------------------
variable "load_balancing_scheme" {
  type        = string
  description = "(optional) Type of load balancer to use (INTERNAL, EXTERNAL, or NONE)"
  default     = "INTERNAL"

  validation {
    condition     = var.load_balancing_scheme == "INTERNAL" || var.load_balancing_scheme == "EXTERNAL" || var.load_balancing_scheme == "NONE"
    error_message = "The load balancing scheme must be INTERNAL, EXTERNAL, or NONE."
  }
}

variable "health_check_interval" {
  type        = number
  description = "(optional) How often, in seconds, to send a health check"
  default     = 30
}

variable "health_timeout" {
  type        = number
  description = "(optional) How long, in seconds, to wait before claiming failure"
  default     = 15
}

#-----------------------------------------------------------------------------------
# Snapshot Storage
#-----------------------------------------------------------------------------------

variable "snapshot_agent" {
  type = object({
    enabled             = bool
    storage_bucket_name = optional(string)
    grant_iam_roles     = optional(bool, true)
    interval            = optional(string, "30m")
    retention           = optional(number, 336) # 1 week @ 30m interval
  })

  default = {
    enabled         = false
    grant_iam_roles = false
  }

  description = "Manage configuration of the Consul snapshot agent"
  validation {
    condition     = var.snapshot_agent.enabled ? (var.snapshot_agent.storage_bucket_name != null) : true
    error_message = "snapshot_agent.storage_bucket_name must be defined when snapshot agent is enabled"
  }

  validation {
    condition     = var.snapshot_agent.grant_iam_roles ? var.snapshot_agent.enabled : true
    error_message = "snapshot_agent.grant_iam_roles must not be true if snapshot agent is disabled"
  }
}
