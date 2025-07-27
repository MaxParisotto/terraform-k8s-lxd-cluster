terraform {
  required_version = ">= 1.0"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 0.20.0"
    }
    maas = {
      source  = "canonical/maas"
      version = "~> 2.6.0"
    }
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 1.7.0"
    }
  }
}
