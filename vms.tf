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


# Provision all required VMs with vault-pki-overlay.yaml mapping
locals {
  nodes = ["t42s-node1", "t42s-node2", "t42s-node3", "t42s-node4"]
  
  # Bundle.yaml + vault-pki-overlay.yaml mapping
  # Each role has distinct cores+memory+disk for mutual exclusion
  
  # Machine 0: easyrsa (unique: 1 core, 4GB RAM, 16GB disk)
  easyrsa = [{
    name = "easyrsa-0"
    hostname = "easyrsa-0"
    vm_host = local.nodes[0]
    cores = 1
    memory = 4096
    longhorn_disk = false
    boot_disk_size = 16
    bundle_machine = "machine-0"
  }]
  
  # Machines 1-3: etcd (unique: 2 cores, 8GB RAM, 20GB disk)
  etcds = [
    {
      name = "etcd-1"
      hostname = "etcd-1"
      vm_host = local.nodes[0]
      cores = 2
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 20
      bundle_machine = "machine-1"
    },
    {
      name = "etcd-2"
      hostname = "etcd-2"
      vm_host = local.nodes[1]
      cores = 2
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 20
      bundle_machine = "machine-2"
    },
    {
      name = "etcd-3"
      hostname = "etcd-3"
      vm_host = local.nodes[2]
      cores = 2
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 20
      bundle_machine = "machine-3"
    }
  ]
  
  # Machine 4: load balancer (unique: 4 cores, 8GB RAM, 16GB disk)
  load_balancers = [{
    name = "lb-1"
    hostname = "lb-1"
    vm_host = local.nodes[3]
    cores = 4
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 16
    bundle_machine = "machine-4"
  }]
  
  # Machines 5-8: control plane (unique: 4 cores, 8GB RAM, 16GB disk)
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
  
  # Machines 9-12: workers (unique: 8 cores, 16GB RAM, 64GB disk + 300GB Longhorn)
  workers = [
    {
      name = "worker-1"
      hostname = "worker-1"
      vm_host = local.nodes[0]
      cores = 8
      memory = 16384
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-9"
    },
    {
      name = "worker-2"
      hostname = "worker-2"
      vm_host = local.nodes[1]
      cores = 8
      memory = 16384
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-10"
    },
    {
      name = "worker-3"
      hostname = "worker-3"
      vm_host = local.nodes[2]
      cores = 8
      memory = 16384
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-11"
    },
    {
      name = "worker-4"
      hostname = "worker-4"
      vm_host = local.nodes[3]
      cores = 8
      memory = 16384
      longhorn_disk = true
      boot_disk_size = 64
      bundle_machine = "machine-12"
    }
  ]
  
  # Machines 12-14: MySQL for vault-pki-overlay (unique: 2 cores, 8GB RAM, 64GB disk)
  mysql_cluster = [
    {
      name = "mysql-1"
      hostname = "mysql-1"
      vm_host = local.nodes[0]
      cores = 2
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 64
      bundle_machine = "machine-12"
    },
    {
      name = "mysql-2"
      hostname = "mysql-2"
      vm_host = local.nodes[1]
      cores = 2
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 64
      bundle_machine = "machine-13"
    },
    {
      name = "mysql-3"
      hostname = "mysql-3"
      vm_host = local.nodes[2]
      cores = 2
      memory = 8192
      longhorn_disk = false
      boot_disk_size = 64
      bundle_machine = "machine-14"
    }
  ]
  
  # Machine 15: Vault for vault-pki-overlay (unique: 2 cores, 16GB RAM, 32GB disk)
  vault = [{
    name = "vault-1"
    hostname = "vault-1"
    vm_host = local.nodes[3]
    cores = 6
    memory = 16384
    longhorn_disk = false
    boot_disk_size = 32
    bundle_machine = "machine-15"
  }]
  
  # Machine 16: spare (unique: 2 cores, 8GB RAM, 16GB disk)
  spare = [{
    name = "spare-1"
    hostname = "spare-1"
    vm_host = local.nodes[0]
    cores = 2
    memory = 8192
    longhorn_disk = false
    boot_disk_size = 16
    bundle_machine = "machine-16"
  }]
  
  # Total: 17 VMs matching bundle.yaml + vault-pki-overlay machines 0-16
  all_vms = concat(local.easyrsa, local.etcds, local.load_balancers, local.control_planes, local.workers, local.mysql_cluster, local.vault, local.spare)
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

  # Add a 300GB extra disk for Longhorn to workers only
  dynamic "storage_disks" {
    for_each = each.value.longhorn_disk == true ? [1] : []
    content {
      size_gigabytes = 300
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
                   "machine-15", "machine-16"])
  name     = each.key
}
