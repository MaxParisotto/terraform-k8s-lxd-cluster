# First, we need to get the VM host data
data "maas_vm_host" "lxd_hosts" {
  for_each = toset([
    "t42s-lxd-cluster-node-1",
    "t42s-lxd-cluster-node-2",
    "t42s-lxd-cluster-node-3",
    "t42s-lxd-cluster-node-4"
  ])
  name = each.key
}

# Create VMs on MAAS-managed LXD hosts
resource "maas_vm_host_machine" "k8s_vms" {
  for_each = {
    "k8s-cp-1"     = { cores = 4, memory = 8192, disk = 50, host = "t42s-lxd-cluster-node-1" }
    "k8s-cp-2"     = { cores = 4, memory = 8192, disk = 50, host = "t42s-lxd-cluster-node-2" }
    "k8s-cp-3"     = { cores = 4, memory = 8192, disk = 50, host = "t42s-lxd-cluster-node-3" }
    "k8s-worker-1" = { cores = 8, memory = 16384, disk = 100, host = "t42s-lxd-cluster-node-2" }
    "k8s-worker-2" = { cores = 8, memory = 16384, disk = 100, host = "t42s-lxd-cluster-node-4" }
    "k8s-worker-3" = { cores = 8, memory = 16384, disk = 100, host = "t42s-lxd-cluster-node-4" }
  }

  hostname = each.key
  vm_host  = data.maas_vm_host.lxd_hosts[each.value.host].id
  cores    = each.value.cores
  memory   = each.value.memory

  network_interfaces {
    name        = "eth0"
    subnet_cidr = "172.16.0.0/12"
  }

  # Main OS/data disk
  storage_disks {
    size_gigabytes = each.value.disk
  }
}

# Get the machines that were created
data "maas_machine" "k8s_vms" {
  for_each = maas_vm_host_machine.k8s_vms

  hostname = each.value.hostname

  depends_on = [maas_vm_host_machine.k8s_vms]
}

# Deploy the VMs with Ubuntu
resource "maas_instance" "k8s_vms" {
  for_each = data.maas_machine.k8s_vms

  allocate_params {
    system_id = each.value.id
  }

  deploy_params {
    distro_series = "noble"
  }

  depends_on = [data.maas_machine.k8s_vms]
}

# Add machines to Juju model
resource "juju_machine" "from_maas" {
  for_each = maas_instance.k8s_vms
  model    = juju_model.k8s_bare_metal.name

  base        = "ubuntu@24.04"
  constraints = "tags=${each.key}"

  depends_on = [maas_instance.k8s_vms]
}
