# MAAS provider configuration
provider "maas" {
  api_url = "http://192.168.1.100:5240/MAAS/"
  api_key = "233ngalSSo2BmJoStJ:TALc45zXO0XL106xxq:o5kef17oOXnztbr5JzFEwENWbGmDTqW9"
}
# Explicit resources for each Vault VM, one per node
resource "lxd_instance" "vault_node1" {
  name   = "vault-node1"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.12"
    }
  }
}

resource "lxd_instance" "vault_node2" {
  name   = "vault-node2"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.22"
    }
  }
}

resource "lxd_instance" "vault_node3" {
  name   = "vault-node3"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.32"
    }
  }
}

resource "lxd_instance" "vault_node4" {
  name   = "vault-node4"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.42"
    }
  }
}

# Explicit resources for each Database VM, one per node
resource "lxd_instance" "db_node1" {
  name   = "db-node1"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.13"
    }
  }
}

resource "lxd_instance" "db_node2" {
  name   = "db-node2"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.23"
    }
  }
}

resource "lxd_instance" "db_node3" {
  name   = "db-node3"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.33"
    }
  }
}

resource "lxd_instance" "db_node4" {
  name   = "db-node4"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "4"
    memory = "8GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.43"
    }
  }
}

variable "lxd_nodes" {
  type = map(string)
  default = {
    node1 = "t42s-node1"
    node2 = "t42s-node2"
    node3 = "t42s-node3"
    node4 = "t42s-node4"
  }
}

variable "control_plane_ips" {
  type = map(string)
  default = {
    node1 = "172.16.0.11"
    node2 = "172.16.0.21"
    node3 = "172.16.0.31"
    node4 = "172.16.0.41"
  }
}


# Explicit resources for each control plane VM, one per node
resource "lxd_instance" "control_plane_node1" {
  name   = "k8s-control-plane-node1"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "8"
    memory = "16GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.11"
    }
  }
}

resource "lxd_instance" "control_plane_node2" {
  name   = "k8s-control-plane-node2"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "8"
    memory = "16GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.21"
    }
  }
}

resource "lxd_instance" "control_plane_node3" {
  name   = "k8s-control-plane-node3"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "8"
    memory = "16GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.31"
    }
  }
}

resource "lxd_instance" "control_plane_node4" {
  name   = "k8s-control-plane-node4"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"
  limits = {
    cpu    = "8"
    memory = "16GB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
    }
  }
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdfan0"
      "ipv4.address" = "172.16.0.41"
    }
  }
}
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
