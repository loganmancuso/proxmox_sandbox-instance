##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

resource "random_pet" "manager_name" {
  length = 3
}

locals {
  manager_vm_id              = 20110
  deployed_node      = "pve-manager"
  manager_ip_addr            = "192.168.10.10/24"
}

resource "proxmox_virtual_environment_vm" "manager" {
  # Instance Description
  name        = random_pet.manager_name.id
  description = "# Manager Server \n## ${random_pet.manager_name.id}"
  tags        = ["k8"]
  node_name   = local.deployed_node
  vm_id       = local.manager_vm_id
  # Instance Config
  clone {
    vm_id = 100 # Jammy-k8
  }
  on_boot = true
  startup {
    order      = local.manager_vm_id
    up_delay   = "60"
    down_delay = "60"
  }
  operating_system {
    type = "l26"
  }
  agent {
    enabled = true
  }
  boot_order = ["virtio0"] # 10.29.23 right now boot_order doesnt set the parameter on creation must set manually
  # Instance Hardware
  cpu {
    architecture = "x86_64"
    cores        = 1
    type         = "x86-64-v2-AES"
  }
  memory {
    dedicated = 2048
  }
  vga {
    type = "qxl"
  }
  network_device {
    bridge   = "vmbr0"
    vlan_id  = 10
    firewall = true
  }
  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "virtio0"
    file_format  = "raw"
  }
  serial_device {}

  # Instance CloudConfig Bootstrap
  initialization {
    ip_config {
      ipv4 {
        address = local.manager_ip_addr
        gateway = "192.168.10.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.bootstrap.id
  }
}

resource "proxmox_virtual_environment_file" "bootstrap" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.deployed_node

  source_raw {
    file_name = "${random_pet.manager_name.id}.cloud-config.yaml"
    data      = <<EOF
#cloud-config
hostname: ${random_pet.manager_name.id}.local
users:
  - name: ${local.instance_credentials["username"]}
    primary_group: ${local.instance_credentials["username"]}
    plain_text_passwd: ${local.instance_credentials["password"]}
    lock_passwd: false
    ssh-authorized-keys:
      - ${trimspace(local.instance_credentials["key"])}
    sudo: ALL=(ALL) NOPASSWD:ALL
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - git
  - wget
  - curl
  - unzip
runcmd:
  - [ sh, -c, "echo $(date) ': Starting Bootstrap'" ]
  - [ sh, -c, "echo $(date) ': ==== START Resize LVM ===='" ]
  - [ sh, -c, growpart /dev/vda 3 ]
  - [ sh, -c, pvresize /dev/vda3 ]
  - [ sh, -c, lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv ]
  - [ sh, -c, resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv ]
  - [ sh, -c, "echo $(date) ': ==== END Resize LVM ===='" ]
EOF
  }
}