##############################################################################
#
# Author: Logan Mancuso
# Created: 11.28.2023
#
##############################################################################

locals {
  vm_id            = 20999
  vm_name          = "test-instance"
  ip_addr          = "192.168.10.240"
  bootstrap_src    = "${path.module}/scripts/bootstrap.sh"
  bootstrap_dst    = "/opt/tofu/bootstrap.sh"
  bootstrap_cmd    = "ssh -t ${local.secret_instance_credentials.username}@${local.ip_addr} 'chmod u+x,g+x ${local.bootstrap_dst} && ${local.bootstrap_dst}'"
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
    cores        = 1
    type         = "x86-64-v2-AES"
  }
  memory {
    dedicated = 1025
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
        gateway = local.vpc_gateway_network_ip
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.bootstrap.id
  }
  provisioner "file" {
    when        = create
    content     = templatefile(local.bootstrap_src,
      {
        log_dst = "/var/log/tofu/bootstrap.log"
      }
    )
    destination = local.bootstrap_dst
    connection {
      type        = "ssh"
      user        = local.secret_instance_credentials.username
      private_key = file("~/.ssh/id_ed25519")
      host        = local.ip_addr
    }
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
  - [ sh, -c, "echo $(date) ': Resizing LVM'" ]
  - [ sh, -c, growpart /dev/vda 3 ]
  - [ sh, -c, pvresize /dev/vda3 ]
  - [ sh, -c, lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv ]
  - [ sh, -c, resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv ]
EOF
  }
}

resource "null_resource" "bootstrap_instance" {
  depends_on = [ proxmox_virtual_environment_vm.test_instance ]
  triggers = {
    bootstrap_file = "${md5(file("${local.bootstrap_src}"))}"
  }
  provisioner "local-exec" {
    command = local.bootstrap_cmd
  }
}