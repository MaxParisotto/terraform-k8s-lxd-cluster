# Juju machines for each MAAS VM
resource "juju_machine" "k8s_vms" {
  for_each = { for name, vm in maas_vm_host_machine.k8s_vms : name => vm }
  model    = juju_model.k8s_model.name
  # No instance_id argument supported; machines will be created in order
}
