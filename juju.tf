provider "juju" {}

resource "juju_application" "calico" {
  name    = "calico"
  model   = "k8s-cloud"
  charm {
    name    = "calico"
    channel = "1.32/stable"
  }
  # vxlan is not a supported argument; if needed, set as an option in the options block
  # options = { vxlan = "Always" }
}

resource "juju_application" "containerd" {
  name    = "containerd"
  model   = "k8s-cloud"
  charm {
    name    = "containerd"
    channel = "1.32/stable"
  }
}

resource "juju_application" "easyrsa" {
  name    = "easyrsa"
  model   = "k8s-cloud"
  charm {
    name    = "easyrsa"
    channel = "1.32/stable"
  }
  constraints = "cores=1 mem=4G root-disk=16G"
  units = 1
}

resource "juju_application" "etcd" {
  name    = "etcd"
  model   = "k8s-cloud"
  charm {
    name    = "etcd"
    channel = "1.32/stable"
  }
  constraints = "cores=2 mem=8G root-disk=16G"
  units = 3
  # channel is not a top-level argument; already set in charm block
}

resource "juju_application" "kubeapi_load_balancer" {
  name    = "kubeapi-load-balancer"
  model   = "k8s-cloud"
  charm {
    name    = "kubeapi-load-balancer"
    channel = "1.32/stable"
  }
  constraints = "cores=1 mem=4G root-disk=16G"
  # exposed is not a supported argument; expose via juju_expose resource if needed
}

resource "juju_application" "kubernetes_control_plane" {
  name    = "kubernetes-control-plane"
  model   = "k8s-cloud"
  charm {
    name    = "kubernetes-control-plane"
    channel = "1.32/stable"
  }
  constraints = "cores=2 mem=8G root-disk=16G"
  units = 2
  # channel is not a top-level argument; already set in charm block
}

resource "juju_application" "kubernetes_worker" {
  name    = "kubernetes-worker"
  model   = "k8s-cloud"
  charm {
    name    = "kubernetes-worker"
    channel = "1.32/stable"
  }
  constraints = "cores=2 mem=8G root-disk=16G"
  units = 3
  # exposed and channel are not supported; channel is set in charm block
}

resource "juju_application" "vault" {
  name    = "vault"
  model   = "k8s-cloud"
  charm {
    name    = "vault"
    channel = "1.16/stable"
  }
}

# Relations (integrations)
resource "juju_integration" "cp_lb_external" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "loadbalancer-external"
  }
  application {
    name     = juju_application.kubeapi_load_balancer.name
    endpoint = "lb-consumers"
  }
}

resource "juju_integration" "cp_lb_internal" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "loadbalancer-internal"
  }
  application {
    name     = juju_application.kubeapi_load_balancer.name
    endpoint = "lb-consumers"
  }
}

resource "juju_integration" "cp_worker_kube_control" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "kube-control"
  }
  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "kube-control"
  }
}

resource "juju_integration" "cp_easyrsa_certificates" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "certificates"
  }
  application {
    name     = juju_application.easyrsa.name
    endpoint = "client"
  }
}

resource "juju_integration" "etcd_easyrsa_certificates" {
  model = "k8s-cloud"
  application {
    name     = juju_application.etcd.name
    endpoint = "certificates"
  }
  application {
    name     = juju_application.easyrsa.name
    endpoint = "client"
  }
}

resource "juju_integration" "cp_etcd" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "etcd"
  }
  application {
    name     = juju_application.etcd.name
    endpoint = "db"
  }
}

resource "juju_integration" "worker_easyrsa_certificates" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "certificates"
  }
  application {
    name     = juju_application.easyrsa.name
    endpoint = "client"
  }
}

resource "juju_integration" "lb_easyrsa_certificates" {
  model = "k8s-cloud"
  application {
    name     = juju_application.kubeapi_load_balancer.name
    endpoint = "certificates"
  }
  application {
    name     = juju_application.easyrsa.name
    endpoint = "client"
  }
}

resource "juju_integration" "calico_etcd" {
  model = "k8s-cloud"
  application {
    name     = juju_application.calico.name
    endpoint = "etcd"
  }
  application {
    name     = juju_application.etcd.name
    endpoint = "db"
  }
}

resource "juju_integration" "calico_cp_cni" {
  model = "k8s-cloud"
  application {
    name     = juju_application.calico.name
    endpoint = "cni"
  }
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "cni"
  }
}

resource "juju_integration" "calico_worker_cni" {
  model = "k8s-cloud"
  application {
    name     = juju_application.calico.name
    endpoint = "cni"
  }
  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "cni"
  }
}

resource "juju_integration" "containerd_worker_runtime" {
  model = "k8s-cloud"
  application {
    name     = juju_application.containerd.name
    endpoint = "containerd"
  }
  application {
    name     = juju_application.kubernetes_worker.name
    endpoint = "container-runtime"
  }
}

resource "juju_integration" "containerd_cp_runtime" {
  model = "k8s-cloud"
  application {
    name     = juju_application.containerd.name
    endpoint = "containerd"
  }
  application {
    name     = juju_application.kubernetes_control_plane.name
    endpoint = "container-runtime"
  }
}
