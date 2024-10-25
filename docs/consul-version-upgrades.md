# Consul version upgrades

First review the standard documentation for [upgrading Consul](https://developer.hashicorp.com/consul/docs/upgrading).

## Automated upgrades

This feature requires HashiCorp Cloud Platform (HCP) or self-managed Consul Enterprise. Refer to [the upgrade documentation](https://developer.hashicorp.com/consul/docs/enterprise/upgrades) for additional information.
Consul Enterprise enables the capability of automatically upgrading a cluster of Consul servers to a new version as updated server nodes join the cluster. This automated upgrade will spawn a process which monitors the amount of voting members currently in a cluster. When an equal amount of new server nodes are joined running the desired version, the lower versioned servers will be demoted to non voting members. Demotion of legacy server nodes will not occur until the voting members on the new version match. Once this demotion occurs, the previous versioned servers can be removed from the cluster safely.

Review the [Consul operator autopilot](https://developer.hashicorp.com/consul/commands/operator/autopilot) documentation and complete the [Automated Upgrade](https://developer.hashicorp.com/consul/tutorials/datacenter-operations/autopilot-datacenter-operations#upgrade-migrations) tutorial to learn more about automated upgrades.

### Module options

The module supports specifying the deployment version.

```hcl
variable "consul_install_version" {
  type        = string
  description = "Version of Consul to install, eg. '1.19.0+ent'"
  default     = "1.19.2+ent"
}
```

The module supports the auto upgrade features by using [opportunistic or selective updates](https://cloud.google.com/compute/docs/instance-groups/updating-migs#selective_updates)

```hcl
update_policy {
  type = "OPPORTUNISTIC"
  #type                         = "PROACTIVE"
  instance_redistribution_type = "PROACTIVE"
  minimal_action               = "REPLACE"
  max_surge_fixed              = length(data.google_compute_zones.available.names)
  max_unavailable_fixed        = 0
}
```

This means you should (where possible and to prevent data loss) follow the standard operating procedure and ensure a backup and recovery process is in place and used accordingly. See the tutorial on [backup and restore](https://developer.hashicorp.com/consul/tutorials/operate-consul/backup-and-restore ).

Use the automated upgrade process. Once the upgrade is successful you can update the `var.consul_install_version` in your deployment and replace the `google_compute_instance_template.consul` which will then mean any future server failures in the `google_compute_region_instance_group_manager.consul` resource will relaunch on the correct version. You can also choose to relaunch the instances in a managed manner this way.
