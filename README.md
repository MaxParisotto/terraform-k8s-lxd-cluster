# terraform-k8s-lxd-cluster

## Prerequisites

- Ubuntu 22.04+ (or compatible Linux)
- Terraform (install from <https://www.terraform.io/downloads.html>)
- Ansible (for MAAS tagging, install via `sudo apt install ansible`)
- Access to a MAAS server (API key and URL)

## Setup

### 1. Clone the repository

```sh
git clone <repo-url>
cd terraform-k8s-lxd-cluster
```

### 2. Configure Terraform

Edit `main.tf` and `terraform.tfvars` with your MAAS API URL and API key as needed.

### 3. Provision VMs with Terraform

```sh
terraform init
terraform apply
```

This will create all VMs in MAAS. Tags are created but not assigned automatically.

### 4. Tag MAAS Machines with Ansible

Edit `tag_maas.yml` if you need to adjust hostnames or tags. Then run:

```sh
ansible-playbook tag_maas.yml
```

This will assign the correct tags to each machine in MAAS using the API.

### 5. Deploy Kubernetes and Vault with Juju

Deploy your bundle and overlay manually:

```sh
juju deploy charmed-kubernetes --overlay ./vault-pki-overlay.yaml
```

### 6. Vault Initialization (Manual)

See the [Charmed Kubernetes Vault docs](https://ubuntu.com/kubernetes/charmed-k8s/docs/using-vault) for full details. Example:

```sh
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
```

---
**Notes:**

- All Juju resources are now managed manually (not by Terraform).
- MAAS machine tags are required for correct Juju placement.
- Ansible is used only for remote MAAS tagging.
