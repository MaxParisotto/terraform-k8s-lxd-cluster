# terraform-k8s-lxd-cluster

juju deploy charmed-kubernetes --overlay ./vault-pki-overlay.yaml


https://ubuntu.com/kubernetes/charmed-k8s/docs/using-vault

juju ssh vault/0
export HISTCONTROL=ignorespace  # enable leading space to suppress command history
export VAULT_ADDR='http://localhost:8200'
vault operator init -key-shares=5 -key-threshold=3  # outputs 5 keys and a root token
 vault operator unseal {key1}
 vault operator unseal {key2}
 vault operator unseal {key3}
 VAULT_TOKEN={root token} vault token create -ttl 10m  # outputs a {charm token} to auth the charm
exit
juju run vault/0 authorize-charm token={charm token}


juju config vault default-ttl='720h'


juju run vault/0 reissue-certificates


