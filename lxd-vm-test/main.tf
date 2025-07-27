terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 2.5.0"
    }
  }
}

provider "lxd" {}

resource "lxd_instance" "test_vm" {
  name   = "test-vm"
  type   = "virtual-machine"
  image  = "ubuntu:24.04"

  config = {
    cpu    = 8
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
      network = "lxdfan0"
    }
  }

}