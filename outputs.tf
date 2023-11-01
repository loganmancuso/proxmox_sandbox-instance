##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

output "instance_details" {
  value = {
    name = local.vm_name
    id   = local.vm_id
    ip   = local.ip_addr
  }
}

output "proxmox_vm_details" {
  value = proxmox_virtual_environment_vm.test_instance
}

output "ssh_connect" {
  value = "ssh ${local.ip_addr}"
}