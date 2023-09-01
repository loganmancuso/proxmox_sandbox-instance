##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

resource "random_pet" "instance_name" {
  length = 3
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
    vm_id = 210
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
    user_data_file_id = proxmox_virtual_environment_file.bootstrap.id
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

# Bootstrap
resource "proxmox_virtual_environment_file" "bootstrap" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve-master"
  source_raw {
    data = <<EOF
#cloud-config
hostname: i-${random_pet.instance_name.id}
packages:
  - qemu-guest-agent
users:
  - name: ${local.instance_credentials["username"]}
    groups: sudo
    shell: /bin/bash 
    ssh-authorized-keys:
      - ${trimspace(local.instance_credentials["key"])}
    sudo: ALL=(ALL) NOPASSWD:ALL
runcmd:
  - growpart /dev/vda 3
  - pvresize /dev/vda3
  - lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
  - resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
EOF
    file_name = "i-${random_pet.instance_name.id}.bootstrap.yml"
  }
}
