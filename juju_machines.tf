# Juju machines for each MAAS VM
resource "juju_machine" "k8s_vms" {
  for_each = { for name, vm in maas_vm_host_machine.k8s_vms : name => vm }
  model    = "k8s-cloud"
  base     = "ubuntu@22.04"
  constraints = "arch=amd64 cores=${each.value.cores} mem=${each.value.memory}M"
  # No instance_id argument supported; machines will be created in order
}
