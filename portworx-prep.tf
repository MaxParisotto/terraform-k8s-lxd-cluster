# Prepare nodes for Portworx
resource "null_resource" "portworx_prep" {
  depends_on = [
    juju_integration.control_plane_worker,
    juju_integration.calico_worker
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cat > portworx-values.yaml <<EOF
      # Portworx values for your setup
      clusterName: t42s-px-cluster
      
      # Use your dedicated storage devices
      # Update these based on your actual disk configuration
      storage:
        drives: ["/dev/sdb", "/dev/sdc"]  # Update with your drives
        journalDevice: auto
        
      network:
        dataInterface: bond0  # Your bonded interface
        mgmtInterface: bond0
        
      # Enable security
      security:
        enabled: true
        
      # Monitoring
      monitoring:
        prometheus:
          enabled: true
          exportMetrics: true
          
      # Autopilot
      autopilot:
        enabled: true
        
      # Internal KVDB (since you have 4 nodes)
      kvdb:
        internal: true
        
      # Resources
      resources:
        requests:
          memory: "4Gi"
          cpu: "2"
          
      EOF
      
      echo "Portworx values file created at ./portworx-values.yaml"
      echo "After cluster is up, install Portworx with:"
      echo "kubectl create namespace portworx"
      echo "helm install portworx portworx/portworx --namespace portworx -f portworx-values.yaml"
    EOT
  }
}
