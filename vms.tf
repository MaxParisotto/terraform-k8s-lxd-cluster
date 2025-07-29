


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

# Provision 2 VMs per node: 1 control-plane, 1 worker
resource "maas_vm_host_machine" "k8s_vms" {
  for_each = merge(
    { for node in ["t42s-node1", "t42s-node2", "t42s-node3", "t42s-node4"] :
        "${node}-cp" => {
          hostname = "${node}-cp"
          vm_host  = node
          cores    = 4
          memory   = 8192
        }
    },
    { for node in ["t42s-node1", "t42s-node2", "t42s-node3", "t42s-node4"] :
        "${node}-worker" => {
          hostname = "${node}-worker"
          vm_host  = node
          cores    = 8
          memory   = 16384
        }
    }
  )

  hostname = each.value.hostname
  vm_host  = data.maas_vm_host.lxd_hosts[each.value.vm_host].id
  cores    = each.value.cores
  memory   = each.value.memory
}
