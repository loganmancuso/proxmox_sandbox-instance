##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

locals {
  vm_id             = 20999
  vm_name           = "test-instance"
  ip_addr           = "192.168.10.240"
}

resource "proxmox_virtual_environment_vm" "test_instance" {
  # Instance Description
  name        = local.vm_name
  description = "# Test Instance \n## ${local.vm_name}"
  tags        = ["test"]
  node_name   = local.node_name
  vm_id       = local.vm_id
  # Instance Config
  clone {
    vm_id = local.vm_template_id
  }
  on_boot = true
  startup {
    order      = local.vm_id
    up_delay   = "10"
    down_delay = "10"
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
        address = "${local.ip_addr}/24"
        gateway = "192.168.10.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.bootstrap.id
  }
}

resource "proxmox_virtual_environment_file" "bootstrap" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.node_name

  source_raw {
    file_name = "${local.vm_name}.cloud-config.yaml"
    data      = <<EOF
#cloud-config
hostname: ${local.vm_name}.local
users:
  - name: ${local.instance_username}
    primary_group: ${local.instance_username}
    password: "${local.instance_password_hashed}"
    lock_passwd: false
    ssh-authorized-keys:
      - ${trimspace(local.instance_ssh_pubkey)}
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
