# MAAS profile variable for CLI tagging
variable "maas_profile" {
  description = "The MAAS profile name to use with the MAAS CLI. Should match your 'maas login' profile."
  type        = string
}



# Get the VM host data for all 4 nodes
data "maas_vm_host" "lxd_hosts" {
  for_each = toset([
    "t42s-node1",
    "t42s-node2",
    "t42s-node3",
    "t42s-node4"
  ])
  name = each.key
}


# Provision all required VMs, distributed across 4 nodes
locals {
  nodes = ["t42s-node1", "t42s-node2", "t42s-node3", "t42s-node4"]
  # Distribute roles as evenly as possible
  control_planes = [for i, node in local.nodes : {
    name = "cp-${i+1}"
    hostname = "cp-${i+1}"
    vm_host = node
    cores = 4
    memory = 8192
    longhorn_disk = false
    tags = ["control-plane"]
  }]
  workers = [for i, node in local.nodes : {
    name = "worker-${i+1}"
    hostname = "worker-${i+1}"
    vm_host = node
    cores = 8
    memory = 16384
    longhorn_disk = true
    tags = ["worker"]
  }]
  etcds = [for i, node in slice(local.nodes, 0, 3) : {
    name = "etcd-${i+1}"
    hostname = "etcd-${i+1}"
    vm_host = node
    cores = 2
    memory = 4096
    longhorn_disk = false
    tags = ["etcd"]
  }]
  mysqls = [for i, node in slice(local.nodes, 0, 3) : {
    name = "mysql-${i+1}"
    hostname = "mysql-${i+1}"
    vm_host = node
    cores = 2
    memory = 4096
    longhorn_disk = false
    tags = ["mysql"]
  }]
  vault = [{
    name = "vault-1"
    hostname = "vault-1"
    vm_host = local.nodes[0]
    cores = 2
    memory = 4096
    longhorn_disk = false
    tags = ["vault"]
  }]
  haproxys = [for i, node in slice(local.nodes, 0, 2) : {
    name = "haproxy-${i+1}"
    hostname = "haproxy-${i+1}"
    vm_host = node
    cores = 2
    memory = 4096
    longhorn_disk = false
    tags = ["haproxy"]
  }]
  all_vms = concat(local.control_planes, local.workers, local.etcds, local.mysqls, local.vault, local.haproxys)
}

resource "maas_vm_host_machine" "k8s_vms" {
  for_each = { for vm in local.all_vms : vm.name => vm }

  hostname = each.value.hostname
  vm_host  = data.maas_vm_host.lxd_hosts[each.value.vm_host].id
  cores    = each.value.cores
  memory   = each.value.memory
  # tags argument is not supported by the provider; tagging is handled separately if needed

  # Add a 50GB boot disk to all VMs
  storage_disks {
    size_gigabytes = 50
  }

  # Add a 300GB extra disk for Longhorn to workers only
  dynamic "storage_disks" {
    for_each = each.value.longhorn_disk == true ? [1] : []
    content {
      size_gigabytes = 300
    }
  }
}

# Create MAAS tags for all roles
resource "maas_tag" "roles" {
  for_each = toset(["control-plane", "worker", "etcd", "mysql", "vault", "haproxy"])
  name     = each.key
}




