# ##############################################################################
# #
# # Author: Logan Mancuso
# # Created: 07.30.2023
# #
# ##############################################################################


#######################################
# Datacenter Default Rules
#######################################
resource "proxmox_virtual_environment_cluster_firewall_security_group" "sandbox" {
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
    source  = "dc/${local.network_private}"
    dest    = "dc/${proxmox_virtual_environment_firewall_alias.sandbox.id}"
    proto   = "tcp"
    log     = "alert"
  }

  ######################
  ### Outbound Rules ###
  ######################

}