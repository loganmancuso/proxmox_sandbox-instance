# ##############################################################################
# #
# # Author: Logan Mancuso
# # Created: 07.30.2023
# #
# ##############################################################################


#######################################
# Datacenter Default Rules
#######################################
resource "proxmox_virtual_environment_cluster_firewall_security_group" "test" {
  name    = "sg-${local.vm_name}"
  comment = "SG to access resources on ${local.vm_name}"

  ######################
  ### Inbound Rules ###
  ######################

  ## Cockpit ##
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "inbound-permit-private-all"
    source  = "dc/${local.private_network_id}"
    dest    = "dc/${proxmox_virtual_environment_firewall_alias.test.id}"
    proto   = "tcp"
    log     = "alert"
  }

  ######################
  ### Outbound Rules ###
  ######################

}