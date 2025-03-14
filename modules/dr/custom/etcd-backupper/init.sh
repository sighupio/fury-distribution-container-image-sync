#!/usr/bin/env sh

# Exit on error
set -e

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
ENDPOINT=$(etcdctl endpoint health -w json | yq '[.[] | select(.health == true)][0].endpoint' -r)

# Use only the healthy endpoint for backup
export ETCDCTL_ENDPOINTS=$ENDPOINT

FILENAME="/backup/fury-etcd-snapshot-$(date +'%Y%m%d%H%M').etcdb"

# Create timestamped ETCD snapshot backup
etcdctl snapshot save "$FILENAME"

# Verify the snapshot
etcdutl snapshot status "$FILENAME"
