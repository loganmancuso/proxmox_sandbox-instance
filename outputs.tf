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

output "bootstrap_cmd" {
  description = "command to bootstrap the instance"
  value       = local.bootstrap_cmd
}