#! /bin/bash
set -euo pipefail

LOGFILE="/var/log/consul-cloud-init.log"
SYSTEMD_DIR="${systemd_dir}"
CONSUL_DIR_CONFIG="${consul_dir_config}"
CONSUL_SNAPSHOT_DIR_CONFIG="${consul_snapshot_dir_config}"
CONSUL_DIR_TLS="${consul_dir_config}/tls"
CONSUL_DIR_DATA="${consul_dir_home}/data"
CONSUL_DIR_LICENSE="${consul_dir_home}/license"
CONSUL_DIR_LOGS="${consul_dir_logs}"
CONSUL_DIR_BIN="${consul_dir_bin}"
CONSUL_USER="${consul_user_name}"
CONSUL_GROUP="${consul_group_name}"
PRODUCT="consul"
CONSUL_VERSION="${consul_version}"
VERSION=$CONSUL_VERSION
REQUIRED_PACKAGES="unzip jq"

function log {
  local level="$1"
  local message="$2"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local log_entry="$timestamp [$level] - $message"

  echo "$log_entry" | tee -a "$LOGFILE"
}

function determine_os_distro {
  local os_distro_name=$(grep "^NAME=" /etc/os-release | cut -d"\"" -f2)

  case "$os_distro_name" in
    "Ubuntu"*)
      os_distro="ubuntu"
      ;;
    "CentOS Linux"*)
      os_distro="centos"
      ;;
    "Red Hat"*)
      os_distro="rhel"
      ;;
    *)
      log "ERROR" "'$os_distro_name' is not a supported Linux OS distro."
      exit_script 1
  esac

  echo "$os_distro"
}

function detect_architecture {
  local ARCHITECTURE=""
  local OS_ARCH_DETECTED=$(uname -m)

  case "$OS_ARCH_DETECTED" in
    "x86_64"*)
      ARCHITECTURE="linux_amd64"
      ;;
    "aarch64"*)
      ARCHITECTURE="linux_arm64"
      ;;
		"arm"*)
      ARCHITECTURE="linux_arm"
			;;
    *)
      log "ERROR" "Unsupported architecture detected: '$OS_ARCH_DETECTED'. "
		  exit_script 1
  esac

  echo "$ARCHITECTURE"

}

# https://cloud.google.com/sdk/docs/install-sdk#linux
function install_gcloud_sdk () {
  if [[ -n "$(command -v gcloud)" ]]; then
    echo "INFO: Detected gcloud SDK is already installed."
  else
    echo "INFO: Attempting to install gcloud SDK."
    if [[ -n "$(command -v python)" ]]; then
      curl -sO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz -o google-cloud-sdk.tar.gz
      tar xzf google-cloud-sdk.tar.gz
      ./google-cloud-sdk/install.sh --quiet
    else
      echo "ERROR: gcloud SDK requires Python but it was not detected on system."
      exit_script 5
    fi
  fi
}

function install_packages() {
  local os_distro="$1"

  if [[ "$os_distro" == "ubuntu" ]]; then
    apt-get update -y
    apt-get install -y $REQUIRED_PACKAGES
  elif [[ "$os_distro" == "centos" ]] || [[ "$os_distro" == "rhel" ]]; then
    yum install -y $REQUIRED_PACKAGES
  else
    log "ERROR" "Unable to determine package manager"
  fi
}

# scrape_vm_info gets the required information needed from the cloud's API
function scrape_vm_info {
  # https://cloud.google.com/compute/docs/metadata/default-metadata-values
  #AVAILABILITY_ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/attributes/google-compute-default-region?recursive=true" -H "Metadata-Flavor: Google" )
  AVAILABILITY_ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google"  | cut -d'/' -f4)
  INSTANCE_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
}

# user_create creates a dedicated linux user for Consul
function user_group_create {
  # Create the dedicated as a system group
  groupadd --system $CONSUL_GROUP

  # Create a dedicated user as a system user
  useradd --system -m -d $CONSUL_DIR_CONFIG -g $CONSUL_GROUP $CONSUL_USER
}

# directory_creates creates the necessary directories for Consul
function directory_create {
  # Define all directories needed as an array
  directories=( $CONSUL_DIR_CONFIG $CONSUL_SNAPSHOT_DIR_CONFIG $CONSUL_DIR_DATA $CONSUL_DIR_TLS $CONSUL_DIR_LICENSE $CONSUL_DIR_LOGS )

  # Loop through each item in the array; create the directory and configure permissions
  for directory in "$${directories[@]}"; do
    mkdir -p $directory
    chown $CONSUL_USER:$CONSUL_GROUP $directory
    chmod 755 $directory
  done
}

function checksum_verify {
  local OS_ARCH="$1"

  # https://www.hashicorp.com/en/trust/security
  # checksum_verify downloads the $$PRODUCT binary and verifies its integrity
  log "INFO" "Verifying the integrity of the $${PRODUCT} binary."
  export GNUPGHOME=./.gnupg
  log "INFO" "Importing HashiCorp GPG key."
  sudo curl -s https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import

	log "INFO" "Downloading $${PRODUCT} binary"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_"$${OS_ARCH}".zip
	log "INFO" "Downloading Vault Enterprise binary checksum files"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_SHA256SUMS
	log "INFO" "Downloading Vault Enterprise binary checksum signature file"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig
  log "INFO" "Verifying the signature file is untampered."
  gpg --verify "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS
	if [[ $? -ne 0 ]]; then
		log "ERROR" "Gpg verification failed for SHA256SUMS."
		exit_script 1
	fi
  if [ -x "$(command -v sha256sum)" ]; then
		log "INFO" "Using sha256sum to verify the checksum of the $${PRODUCT} binary."
		sha256sum -c "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS --ignore-missing
	else
		log "INFO" "Using shasum to verify the checksum of the $${PRODUCT} binary."
		shasum -a 256 -c "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS --ignore-missing
	fi
	if [[ $? -ne 0 ]]; then
		log "ERROR" "Checksum verification failed for the $${PRODUCT} binary."
		exit_script 1
	fi

	log "INFO" "Checksum verification passed for the $${PRODUCT} binary."

	log "INFO" "Removing the downloaded files to clean up"
	sudo rm -f "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig

}


# # install_consul_binary downloads the Consul binary and puts it in dedicated bin directory
# function install_consul_binary {
#   log "INFO" "Downloading Consul Enterprise binary"
#   curl -so $CONSUL_DIR_BIN/consul.zip $CONSUL_INSTALL_URL

#   log "INFO" "Unzipping Consul Enterprise binary to $CONSUL_DIR_BIN"
#   unzip $CONSUL_DIR_BIN/consul.zip consul -d $CONSUL_DIR_BIN
#   # unzip $CONSUL_DIR_BIN/consul.zip -x consul -d $CONSUL_DIR_LICENSE

#   rm $CONSUL_DIR_BIN/consul.zip
# }

function fetch_tls_certificates {
  log "INFO" "Retrieving TLS certificate '${consul_tls_cert_sm_secret_name}' from Secret Manager."
  gcloud secrets versions access latest --secret=${consul_tls_cert_sm_secret_name} | base64 -d > $CONSUL_DIR_TLS/cert.pem

  log "INFO" "Retrieving TLS private key '${consul_tls_privkey_sm_secret_name}' from Secret Manager."
  gcloud secrets versions access latest --secret=${consul_tls_privkey_sm_secret_name} | base64 -d > $CONSUL_DIR_TLS/key.pem

  log "INFO" "Retrieving TLS CA certificate '${consul_tls_ca_bundle_sm_secret_name}' from Secret Manager."
  gcloud secrets versions access latest --secret=${consul_tls_ca_bundle_sm_secret_name} | base64 -d > $CONSUL_DIR_TLS/ca.pem

  log "INFO" "Setting certificate file permissions and ownership"
  chown $CONSUL_USER:$CONSUL_GROUP $CONSUL_DIR_TLS/*
  chmod 660 $CONSUL_DIR_TLS/cert.pem $CONSUL_DIR_TLS/key.pem
  chmod 664 $CONSUL_DIR_TLS/ca.pem
}

function fetch_consul_license {
  log "INFO" "Retrieving Consul license '${consul_license_sm_secret_name}' from Secret Manager."
  gcloud secrets versions access latest --secret=${consul_license_sm_secret_name} > $CONSUL_DIR_LICENSE/license.hclic

  log "INFO" "Setting license file permissions and ownership"
  chown $CONSUL_USER:$CONSUL_GROUP $CONSUL_DIR_LICENSE/license.hclic
  chmod 660 $CONSUL_DIR_LICENSE/license.hclic
}

function fetch_consul_gossip_key {
  log "INFO" "Retrieving Consul gossip encryption key '${consul_gossip_key_sm_secret_name}' from Secret Manager."
  export GOSSIP_KEY=$(gcloud secrets versions access latest --secret=${consul_gossip_key_sm_secret_name})
}

function generate_consul_config {
  bash -c "cat > $CONSUL_DIR_CONFIG/server.hcl" <<EOF
server           = true
datacenter       = "${consul_datacenter}"
client_addr      = "0.0.0.0"
bootstrap_expect = ${consul_nodes}
license_path     = "$${CONSUL_DIR_LICENSE}/license.hclic"
data_dir         = "$${CONSUL_DIR_DATA}"
encrypt          = "$${GOSSIP_KEY}"

retry_join = ["provider=gce zone_pattern=${auto_join_zone_pattern} tag_value=${auto_join_tag_value}"]

tls {
  defaults {
    ca_file         = "$${CONSUL_DIR_TLS}/ca.pem"
    cert_file       = "$${CONSUL_DIR_TLS}/cert.pem"
    key_file        = "$${CONSUL_DIR_TLS}/key.pem"
    verify_incoming = false
    verify_outgoing = true
  }

  internal_rpc {
    verify_incoming        = true
    verify_server_hostname = true
  }
}

acl {
  enabled                  = true
  default_policy           = "deny"
  down_policy              = "extend-cache"
  enable_token_persistence = true
}

auto_encrypt {
  allow_tls = true
}

autopilot {
  redundancy_zone_tag = "availability_zone"
  min_quorum          = ${consul_nodes}
}

node_meta {
  availability_zone = "$${AVAILABILITY_ZONE}"
}

connect {
  enabled = true
}

ports {
  http     = 8500
  https    = 8501
  grpc     = -1
  grpc_tls = 8503
}

addresses {
  http = "127.0.0.1"
}

ui_config {
  enabled = true
}
EOF


  log "INFO" "Setting Consul server config file permissions and ownership"
  chmod 600 $CONSUL_DIR_CONFIG/server.hcl
  chown $CONSUL_USER:$CONSUL_GROUP $CONSUL_DIR_CONFIG/server.hcl
}

function generate_consul_systemd_unit_file {
  bash -c "cat > $SYSTEMD_DIR/consul.service" <<EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=$CONSUL_DIR_CONFIG/server.hcl

[Service]
Type=notify
User=$CONSUL_USER
Group=$CONSUL_GROUP
ExecStart=$CONSUL_DIR_BIN/consul agent -config-dir=$CONSUL_DIR_CONFIG
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

  chmod 644 $SYSTEMD_DIR/consul.service
  mkdir /etc/systemd/system/consul.service.d
}

function start_enable_systemd_unit {
  systemctl daemon-reload
  systemctl enable --now "$${1}"
}

function configure_consul_cli {
  bash -c "cat > /etc/profile.d/99-consul-cli-config.sh" <<EOF
export CONSUL_CACERT=$CONSUL_DIR_TLS/ca.pem
export CONSUL_HTTP_ADDR=https://127.0.0.1:8501
%{ if consul_fqdn != "" ~}
export CONSUL_TLS_SERVER_NAME="${consul_fqdn}"
%{ endif ~}
complete -C $CONSUL_DIR_BIN/consul consul
EOF
}

function bootstrap_consul_acls {
  set +e
  read -r -d '' ANONYMOUS_POLICY_DEFINITION <<EOF
partition_prefix "" {
  namespace_prefix "" {
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
  }
}
EOF

  read -r -d '' AGENT_POLICY_DEFINITION <<EOF
partition "default" {
  node_prefix "" {
    policy = "write"
  }
  namespace_prefix "" {
    service_prefix "" {
      policy = "read"
    }
  }
}
EOF

  read -r -d '' SNAPSHOT_POLICY_DEFINITION <<EOF
acl = "write"
key "consul-snapshot/lock" {
  policy = "write"
}
session_prefix "" {
  policy = "write"
}
service "consul-snapshot" {
  policy = "write"
}
EOF

  set -e

  log "INFO" "Waiting for the leader to be established"

  export CONSUL_HTTP_ADDR="http://localhost:8500"

  until curl --fail --silent --show-error $${CONSUL_HTTP_ADDR}/v1/status/leader | grep -qE '(\.|:)+'  ; do
    echo -n "."
    sleep 5
  done

  if RESPONSE="$(curl --fail --silent --show-error --request PUT $${CONSUL_HTTP_ADDR}/v1/acl/bootstrap)" ; then
    MANAGEMENT_TOKEN=$(echo $${RESPONSE} | jq -er .SecretID)
    printf "$${MANAGEMENT_TOKEN}" | gcloud secrets versions add ${application_prefix}-consul-management-token --data-file=-

    export CONSUL_HTTP_TOKEN=$${MANAGEMENT_TOKEN}
    consul acl policy create -name anonymous-policy -description "Permit anonymous access to consul catalog" -rules "$${ANONYMOUS_POLICY_DEFINITION}"
    consul acl token update -accessor-id anonymous -append-policy-name anonymous-policy

    consul acl policy create -name server-agent-policy -description "Policy for Server Agents" -rules "$${AGENT_POLICY_DEFINITION}"
    AGENT_TOKEN=$(consul acl token create -policy-name server-agent-policy -description "Token for Server Agents" -format json | jq -er .SecretID)
    printf "$${AGENT_TOKEN}" | gcloud secrets versions add ${application_prefix}-consul-agent-token --data-file=-

    consul acl policy create -name snapshot-policy -description "Policy for Snapshot Agent" -rules "$${SNAPSHOT_POLICY_DEFINITION}"
    SNAPSHOT_TOKEN=$(consul acl token create -policy-name snapshot-policy -description "Token for Snapshot Agent" -format json | jq -er .SecretID)
    printf "$${SNAPSHOT_TOKEN}" | gcloud secrets versions add ${application_prefix}-consul-snapshot-token --data-file=-

    unset CONSUL_HTTP_TOKEN
  else
    log "INFO" "Waiting for agent token to be set in Secret Manager"
    until AGENT_TOKEN=$(gcloud secrets versions access latest --secret=${application_prefix}-consul-agent-token) 2>/dev/null ; do
      echo -n "."
      sleep 10
    done
  fi
  bash -c "cat > $CONSUL_DIR_CONFIG/agent-token.hcl" <<EOF
acl {
  tokens {
    agent = "$${AGENT_TOKEN}"
  }
}
EOF

  systemctl reload consul.service
}

%{ if snapshot_agent.enabled ~}
function generate_snapshot_agent_systemd_unit {
  bash -c "cat > $${SYSTEMD_DIR}/consul-snapshot.service" <<EOF
[Unit]
Description="HashiCorp Consul Snapshot Agent"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=$${CONSUL_SNAPSHOT_DIR_CONFIG}/consul-snapshot.json

[Service]
Type=simple
User=$${CONSUL_USER}
Group=$${CONSUL_GROUP}
ExecStart=$${CONSUL_DIR_BIN}/consul snapshot agent -config-file=$${CONSUL_SNAPSHOT_DIR_CONFIG}/consul-snapshot.json
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

  chmod 644 $${SYSTEMD_DIR}/consul-snapshot.service
}

function generate_snapshot_agent_config {
  log "INFO" "Waiting for snapshot token to be set in Secret Manager"
  until SNAPSHOT_TOKEN=$(gcloud secrets versions access latest --secret=${application_prefix}-consul-snapshot-token) 2>/dev/null ; do
    echo -n "."
    sleep 10
  done

  bash -c "cat > $${CONSUL_SNAPSHOT_DIR_CONFIG}/consul-snapshot.json" <<EOF
{
  "snapshot_agent": {
    "http_addr": "http://localhost:8500",
    "token": "$${SNAPSHOT_TOKEN}",
    "snapshot": {
      "interval": "${snapshot_agent.interval}",
      "retain": ${snapshot_agent.retention},
      "deregister_after": "8h"
    },
    "backup_destinations": {
      "google_storage": [
        {
          "bucket": "${snapshot_agent.storage_bucket_name}"
        }
      ]
    }
  }
}
EOF
  chown -R $${CONSUL_USER}:$${CONSUL_GROUP} $${CONSUL_SNAPSHOT_DIR_CONFIG}
  chmod 660 $${CONSUL_SNAPSHOT_DIR_CONFIG}/consul-snapshot.json
}
%{ endif ~}

exit_script() {
  if [[ "$1" == 0 ]]; then
    log "INFO" "Consul custom_data script finished successfully!"
  else
    log "ERROR" "Consul custom_data script finished with error code $1."
  fi

  exit "$1"
}

main() {
  log "INFO" "Beginning custom_data script."

  OS_DISTRO=$(determine_os_distro)
  log "INFO" "Detected OS distro is '$OS_DISTRO'."

  OS_ARCH=$(detect_architecture)
	log "INFO" "Detected system architecture is '$OS_ARCH'."

  log "INFO" "Scraping VM metadata required for Consul configuration"
  scrape_vm_info

  log "INFO" "Installing software dependencies"
  install_gcloud_sdk

  log "INFO" "Installing $REQUIRED_PACKAGES"
  install_packages "$OS_DISTRO"

  log "INFO" "Creating Consul system user and group"
  user_group_create

  log "INFO" "Creating directories for Consul config and data"
  directory_create

	checksum_verify $OS_ARCH
	log "INFO" "Checksum verification completed for Vault binary."


  log "INFO" "Retrieving Consul license file from Secret Manager"
  fetch_consul_license

  log "INFO" "Retrieving Consul API TLS certificates from Secret Manager"
  fetch_tls_certificates

  log "INFO" "Retrieving Consul gossip encryption key from Secret Manager"
  fetch_consul_gossip_key

  log "INFO" "Generating Consul server configuration file"
  generate_consul_config

  log "INFO" "Generating Consul systemd unit file"
  generate_consul_systemd_unit_file

  log "INFO" "Starting Consul"
  start_enable_systemd_unit "consul"

  log "INFO" "Bootstrapping Consul ACL system"
  bootstrap_consul_acls

  log "INFO" "Configuring Consul CLI"
  configure_consul_cli

  %{~ if snapshot_agent.enabled ~}
  log "INFO" "Generating snapshot agent configuration file"
  generate_snapshot_agent_config

  log "INFO" "Generating snapshot agent systemd unit file"
  generate_snapshot_agent_systemd_unit

  log "INFO" "Starting Consul snapshot agent"
  start_enable_systemd_unit "consul-snapshot"
  %{~ endif ~}

  exit_script 0
}

main "$@"
