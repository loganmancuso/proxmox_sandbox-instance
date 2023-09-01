##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

output "instance" {
  description = "deployed instance"
  value = {
    name           = proxmox_virtual_environment_vm.instance.name,
    ipv4_addresses = proxmox_virtual_environment_vm.instance.ipv4_addresses[1][0]
  }
}