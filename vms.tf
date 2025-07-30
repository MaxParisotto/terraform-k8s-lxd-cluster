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


# Provision all required VMs aligned with actual Juju deployment
locals {
  nodes = ["t42s-node1", "t42s-node2", "t42s-node3", "t42s-node4"]
  
  # Aligned with actual Juju deployment from status
  # Machine 0-2: MySQL for vault-pki-overlay (unique: 2 cores, 8GB RAM, 64GB disk)
  mysql_cluster = [
    {
      name = "mysql-1"
      hostname = "mysql-1"
      vm_host = local.nodes[0]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 64
      bundle_machine = "machine-17"
    },
    {
      name = "mysql-2"
      hostname = "mysql-2"
      vm_host = local.nodes[2]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 64
      bundle_machine = "machine-18"
    },
    {
      name = "mysql-3"
      hostname = "mysql-3"
      vm_host = local.nodes[1]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 64
      bundle_machine = "machine-19"
    }
  ]
  
  # Machine 3: Vault for vault-pki-overlay (unique: 6 cores, 16GB RAM, 32GB disk)
  vault = [{
    name = "vault-1"
    hostname = "vault-1"
    vm_host = local.nodes[3]
    cores = 6
    memory = 16384
    longhorn_disk = false
    boot_disk_size = 32
    bundle_machine = "machine-20"
  }]
  
  # Machine 4: easyrsa (unique: 1 core, 4GB RAM, 16GB disk)
  easyrsa = [{
    name = "easyrsa-0"
    hostname = "easyrsa-0"
    vm_host = local.nodes[3]
    cores = 4
    memory = 4096
    longhorn_disk = false
    boot_disk_size = 16
    bundle_machine = "machine-4"
  }]
  
  # Machine 5-8: control plane (unique: 4 cores, 8GB RAM, 16GB disk)
  control_planes = [
    {
      name = "cp-1"
      hostname = "cp-1"
      vm_host = local.nodes[0]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 16
      bundle_machine = "machine-5"
    },
    {
      name = "cp-2"
      hostname = "cp-2"
      vm_host = local.nodes[1]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 16
      bundle_machine = "machine-6"
    },
    {
      name = "cp-3"
      hostname = "cp-3"
      vm_host = local.nodes[2]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 16
      bundle_machine = "machine-7"
    },
    {
      name = "cp-4"
      hostname = "cp-4"
      vm_host = local.nodes[3]
      cores = 4
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 16
      bundle_machine = "machine-8"
    }
  ]
  
  # Machine 9: etcd-2
  etcd_2 = [{
    name = "etcd-2"
    hostname = "etcd-2"
    vm_host = local.nodes[1]
    cores = 4
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 20
    bundle_machine = "machine-10"
  }]
  
  # Machine 10: etcd-1
  etcd_1 = [{
    name = "etcd-1"
    hostname = "etcd-1"
    vm_host = local.nodes[2]
    cores = 4
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 20
    bundle_machine = "machine-9"
  }]
  
  # Machine 11: etcd-3
  etcd_3 = [{
    name = "etcd-3"
    hostname = "etcd-3"
    vm_host = local.nodes[0]
    cores = 4
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 20
    bundle_machine = "machine-11"
  }]
  
  # Machine 12: load balancer
  load_balancer = [{
    name = "lb-1"
    hostname = "lb-1"
    vm_host = local.nodes[3]
    cores = 8
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 15
    bundle_machine = "machine-12"
  }]
  
  # Machine 13-16: workers (unique: 16 cores, 32GB RAM, 64GB disk + 300GB Longhorn)
  workers = [
    {
      name = "worker-1"
      hostname = "worker-1"
      vm_host = local.nodes[0]
      cores = 16
      memory = 32768
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-13"
    },
    {
      name = "worker-2"
      hostname = "worker-2"
      vm_host = local.nodes[1]
      cores = 16
      memory = 32768
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-14"
    },
    {
      name = "worker-3"
      hostname = "worker-3"
      vm_host = local.nodes[2]
      cores = 16
      memory = 32768
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-15"
    },
    {
      name = "worker-4"
      hostname = "worker-4"
      vm_host = local.nodes[3]
      cores = 16
      memory = 32768
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-16"
    }
  ]
  
  # Machine 7: spare (unique: 4 cores, 8GB RAM, 16GB disk)
  spare = [{
    name = "spare-1"
    hostname = "spare-1"
    vm_host = local.nodes[2]
    cores = 4
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 16
    bundle_machine = "machine-21"
  }]
  
  # Total: 17 VMs with proper separation of roles
  all_vms = concat(local.mysql_cluster, local.vault, local.easyrsa, local.control_planes, local.etcd_2, local.etcd_1, local.etcd_3, local.load_balancer, local.workers)
}

resource "maas_vm_host_machine" "k8s_vms" {
  for_each = { for vm in local.all_vms : vm.name => vm }

  hostname = each.value.hostname
  vm_host  = data.maas_vm_host.lxd_hosts[each.value.vm_host].id
  cores    = each.value.cores
  memory   = each.value.memory
  # tags argument is not supported by the provider; tagging is handled separately if needed

  # Add boot disk with exact specifications
  storage_disks {
    size_gigabytes = each.value.boot_disk_size
  }

  # Add selective storage disks based on node type
  dynamic "storage_disks" {
    for_each = each.value.longhorn_disk == true ? [1] : []
    content {
      size_gigabytes = 300
    }
  }

  # Add etcd data disk for etcd nodes (minimal size)
  dynamic "storage_disks" {
    for_each = can(regex("etcd-", each.value.name)) ? [1] : []
    content {
      size_gigabytes = 10
    }
  }

  # Add MySQL data disk for MySQL nodes (minimal size)
  dynamic "storage_disks" {
    for_each = can(regex("mysql-", each.value.name)) ? [1] : []
    content {
      size_gigabytes = 20
    }
  }

  # Add Vault data disk for Vault node (minimal size)
  dynamic "storage_disks" {
    for_each = each.value.name == "vault-1" ? [1] : []
    content {
      size_gigabytes = 20
    }
  }
}

# Create MAAS tags for all roles including vault-pki-overlay
resource "maas_tag" "bundle_roles" {
  for_each = toset(["easyrsa", "etcd", "load-balancer", "control-plane", "worker", "mysql", "vault", "spare"])
  name     = each.key
}

# Create MAAS tags for exact machine mapping
resource "maas_tag" "bundle_machines" {
  for_each = toset(["machine-0", "machine-1", "machine-2", "machine-3", "machine-4", 
                   "machine-5", "machine-6", "machine-7", "machine-8", "machine-9",
                   "machine-10", "machine-11", "machine-12", "machine-13", "machine-14",
                   "machine-15", "machine-16", "machine-17", "machine-18", "machine-19",
                   "machine-20", "machine-21"])
  name     = each.key
}
