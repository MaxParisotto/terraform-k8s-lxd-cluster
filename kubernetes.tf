# Deploy Charmed Kubernetes 1.32 with HA
resource "juju_application" "kubernetes_control_plane" {
  name  = "kubernetes-control-plane"
  model = juju_model.k8s_bare_metal.name

  charm {
    name    = "kubernetes-control-plane"
    channel = "1.32/stable"
  }

  units = 3 # HA control plane across 3 nodes

  config = {
    ha-cluster-vip          = "172.16.0.10" # Set a VIP in your range
    ha-cluster-dns          = ""
    enable-metrics          = true
    enable-dashboard-addons = true
    # Portworx friendly settings
    allow-privileged  = true
    enable-cgroups-v2 = false # Portworx may need cgroups v1
  }
  depends_on = [juju_machine.from_maas]
}

resource "juju_application" "kubernetes_worker" {
  name  = "kubernetes-worker"
  model = juju_model.k8s_bare_metal.name

  charm {
    name    = "kubernetes-worker"
    channel = "1.32/stable"
  }

  units = 4 # Workers on all 4 nodes

  config = {
    ingress = true
    # Portworx requirements
    allow-privileged  = true
    enable-cgroups-v2 = false
  }
  depends_on = [juju_machine.from_maas]
}

# Deploy etcd for HA
resource "juju_application" "etcd" {
  name  = "etcd"
  model = juju_model.k8s_bare_metal.name

  charm {
    name    = "etcd"
    channel = "1.32/stable"
  }

  units = 3 # HA etcd cluster

  config = {
    channel = "3.4/stable"
  }
}

# Deploy Vault for PKI
resource "juju_application" "vault" {
  name  = "vault"
  model = juju_model.k8s_bare_metal.name

  charm {
    name    = "vault"
    channel = "1.17/stable"
  }

  units = 3 # HA Vault

  config = {
    # vip removed, not supported by current charm
  }
}

# Deploy MySQL for Vault backend
resource "juju_application" "mysql" {
  name  = "mysql"
  model = juju_model.k8s_bare_metal.name # Now runs on MAAS

  charm {
    name    = "mysql-innodb-cluster"
    channel = "latest/edge"
  }

  units = 3 # HA MySQL cluster
}

# Deploy HAProxy for load balancing
resource "juju_application" "haproxy" {
  name  = "haproxy"
  model = juju_model.k8s_bare_metal.name # Now runs on MAAS

  charm {
    name    = "haproxy"
    channel = "latest/stable"
  }

  units = 1
}

# Deploy ContainerD
resource "juju_application" "containerd" {
  name  = "containerd"
  model = juju_model.k8s_bare_metal.name

  charm {
    name    = "containerd"
    channel = "latest/stable"
  }

  config = {
    # Portworx compatible settings
    custom_registries = jsonencode([])
  }
}

# Deploy Calico CNI
resource "juju_application" "calico" {
  name  = "calico"
  model = juju_model.k8s_bare_metal.name

  charm {
    name    = "calico"
    channel = "latest/stable"
  }

  config = {
    vxlan = "Always" # Good for your setup
    # prometheus-port removed, not supported by current charm
  }
}

# ===== RELATIONS =====

# Core Kubernetes relations
resource "juju_integration" "control_plane_worker" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "kube-control"
  }

  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "kube-control"
  }
}

resource "juju_integration" "control_plane_etcd" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "etcd"
  }

  application {
    name     = juju_application.etcd.name
    endpoint = "db"
  }
}

# Vault relations
resource "juju_integration" "vault_mysql" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.vault.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.mysql.name
    endpoint = "shared-db"
  }

  # via removed, all in same model
}

resource "juju_integration" "etcd_vault" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.etcd.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.vault.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "control_plane_vault" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.vault.name
    endpoint = "certificates"
  }
}

resource "juju_integration" "worker_vault" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.vault.name
    endpoint = "certificates"
  }
}

# Container runtime relations
resource "juju_integration" "containerd_control_plane" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.containerd.name
    endpoint = "containerd"
  }

  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "container-runtime"
  }
}

resource "juju_integration" "containerd_worker" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.containerd.name
    endpoint = "containerd"
  }

  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "container-runtime"
  }
}

# CNI relations
resource "juju_integration" "calico_control_plane" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.calico.name
    endpoint = "cni"
  }

  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "cni"
  }
}

resource "juju_integration" "calico_worker" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.calico.name
    endpoint = "cni"
  }

  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "cni"
  }
}

resource "juju_integration" "calico_etcd" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.calico.name
    endpoint = "etcd"
  }

  application {
    name     = juju_application.etcd.name
    endpoint = "db"
  }
}

# HAProxy relations
resource "juju_integration" "haproxy_control_plane" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.haproxy.name
    endpoint = "reverseproxy"
  }

  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "loadbalancer"
  }

  # via removed, all in same model
}

# Additional relations for completeness
resource "juju_integration" "haproxy_vault" {
  model = juju_model.k8s_bare_metal.name

  application {
    name     = juju_application.haproxy.name
    endpoint = "reverseproxy"
  }

  application {
    name     = juju_application.vault.name
    endpoint = "loadbalancer"
  }

  # via removed, all in same model
}
