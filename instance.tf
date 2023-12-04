##############################################################################
#
# Author: Logan Mancuso
# Created: 11.28.2023
#
##############################################################################

locals {
  vm_id   = 20999
  vm_name = "test-instance"
  ip_addr = "192.168.10.240"
}

resource "proxmox_virtual_environment_vm" "test_instance" {
  # Instance Description
  name        = local.vm_name
  description = "# Test Instance \n## ${local.vm_name}"
  tags        = concat(local.default_tags, ["test"])
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
    cores        = 4
    type         = "x86-64-v2-AES"
  }
  memory {
    dedicated = 4096
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
  - name: ${local.secret_instance_credentials.username}
    primary_group: ${local.secret_instance_credentials.username}
    password: "${local.secret_instance_credentials.hashed_password}"
    lock_passwd: false
    ssh-authorized-keys:
      - ${trimspace(local.secret_instance_credentials.pub_key)}
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
  - [ sh, -c, growpart /dev/vda 3 ]
  - [ sh, -c, pvresize /dev/vda3 ]
  - [ sh, -c, lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv ]
  - [ sh, -c, resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv ]
  - [ sh, -c, pip install psutil ]
EOF
  }
}

resource "null_resource" "bootstrap_instance" {
  depends_on = [proxmox_virtual_environment_vm.test_instance]
  triggers = {
    bootstrap_file = "${md5(file("${path.module}/scripts/bootstrap.py"))}"
  }
  provisioner "local-exec" {
    command = "scp -C ${path.module}/scripts/bootstrap.py ${local.secret_instance_credentials.username}@${local.ip_addr}:/opt/tofu/ && ssh -t ${local.secret_instance_credentials.username}@${local.ip_addr} 'cloud-init status --wait && python3 /opt/tofu/bootstrap.py'"
  }
}