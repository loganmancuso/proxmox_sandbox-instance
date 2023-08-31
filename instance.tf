##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

resource "random_pet" "instance_name" {
  length   = 3
}

resource "proxmox_virtual_environment_vm" "instance" {
  name        = "i-${random_pet.instance_name.id}"
  description = "# Sandbox Instance \n## Name: ${random_pet.instance_name.id}"
  tags        = ["instance"]

  node_name = "pve-master"
  vm_id     = var.instance.id

  on_boot = true
  agent {
    enabled = true
  }
  cpu {
    architecture = "x86_64"
    cores        = 2
  }
  memory {
    dedicated = 2048
  }
  startup {
    order      = var.instance.id
    up_delay   = "60"
    down_delay = "60"
  }
  clone {
    vm_id = 9000
  }
  disk {
    datastore_id = "local-lvm"
    size         = 50
    interface    = "virtio0"
  }
  initialization {
    ip_config {
      ipv4 {
        address = var.instance.ip
        gateway = "192.168.10.1"
      }
    }

    user_account {
      keys = [
        trimspace(local.instance_credentials["key"])
      ]
      username = local.instance_credentials["username"]
      password = local.instance_credentials["password"]
    }

  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 10
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
