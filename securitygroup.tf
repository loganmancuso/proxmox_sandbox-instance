# ##############################################################################
# #
# # Author: Logan Mancuso
# # Created: 07.30.2023
# #
# ##############################################################################


#######################################
# Datacenter Default Rules
#######################################
resource "proxmox_virtual_environment_cluster_firewall_security_group" "manager" {
  name    = "sg-manager"
  comment = "SG to access Data Resources on manager Server"

  ######################
  ### Inbound Rules ###
  ######################

  ## Cockpit ##
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "inbound-permit-private-cockpit"
    source  = "dc/${local.private_network_id}"
    dest    = "dc/${proxmox_virtual_environment_firewall_alias.manager.id}"
    dport   = 9090
    proto   = "tcp"
    log     = "alert"
  }

  ######################
  ### Outbound Rules ###
  ######################

}