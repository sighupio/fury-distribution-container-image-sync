#!/usr/bin/env sh

# Configuration file path
CONFIG_FILE="/k8s/config.yaml"

# Load ETCD endpoints from config file if it exists
if [ -f "$CONFIG_FILE" ]; then
    ENDPOINTS=$(yq eval '.etcd.external.endpoints | join(",")' "$CONFIG_FILE")

    [ -n "$ENDPOINTS" ] && ETCDCTL_ENDPOINTS="$ENDPOINTS"
fi

# Set ETCD client environment variables
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS="$ETCDCTL_ENDPOINTS"
export ETCDCTL_CACERT="$ETCDCTL_CACERT"
export ETCDCTL_CERT="$ETCDCTL_CERT"
export ETCDCTL_KEY="$ETCDCTL_KEY"

# Select the first healthy endpoint
ENDPOINT=$(etcdctl endpoint health -w json | jq '[.[] | select(.health == true)][0].endpoint' -r)

# Use only the healthy endpoint for backup
export ETCDCTL_ENDPOINTS=$ENDPOINT

# Create timestamped ETCD snapshot backup
etcdctl snapshot save /backup/fury-etcd-snapshot-$(date +'%Y%m%d%H%M').etcdb
