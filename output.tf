output "vault_units" {
  value       = juju_application.vault.units
  description = "Vault units for initialization"
}

output "kubernetes_vip" {
  value       = "172.16.0.10"
  description = "Kubernetes API VIP"
}

output "vault_vip" {
  value       = "172.16.0.11"
  description = "Vault VIP"
}

output "kubeconfig_cmd" {
  value       = "juju ssh kubernetes-control-plane/leader -- cat /home/ubuntu/config > ~/.kube/config"
  description = "Command to retrieve kubeconfig"
}

output "portworx_install" {
  value       = <<-EOT
    After cluster is ready:
    1. Get kubeconfig: juju ssh kubernetes-control-plane/leader -- cat /home/ubuntu/config > ~/.kube/config
    2. Install Portworx:
       kubectl create namespace portworx
       helm repo add portworx https://raw.githubusercontent.com/portworx/charts/master/stable
       helm install portworx portworx/portworx --namespace portworx -f portworx-values.yaml
  EOT
  description = "Portworx installation instructions"
}
