# Create a model for Kubernetes on bare metal
resource "juju_model" "k8s_bare_metal" {
  name = "kubernetes-prod"

  cloud {
    name   = "maas-cloud"
    region = "default"
  }

  config = {
    default-series = "noble"
    logging-config = "<root>=INFO"
  }
}

# Create a model for support services on LXD
resource "juju_model" "k8s_support" {
  name = "kubernetes-support"

  cloud {
    name   = "t42s-lxd-cluster"
    region = "default"
  }

  config = {
    default-series = "noble"
  }
}
