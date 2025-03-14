# etcd-backupper
A simple Alpine-based image which contains `etcdctl` and `yq`
to assist the `etcd-backup-*` features.

## Endpoint detection
There is some logic to try to automatically detect which endpoints
are the `etcd` servers listening on, but in order to make this work
you have to mount the `ClusterConfiguration` config-map as a volume
under `/k8s/config.yaml`. If this isn't mounted, we rely on 
what's provided by outside.

## Health detection
Since the `etcdctl snapshot save` command needs one and
only one endpoint to perform the snapshot, we need to
choose which one. This is chosen by asking the whole
etcd cluster which node is healthy. Then we snapshot that
node.
