##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

resource "proxmox_virtual_environment_firewall_alias" "sandbox" {
  name    = local.vm_name
  cidr    = "${local.ip_addr}/24"
  comment = "${local.vm_name} instance ip"
}

resource "proxmox_virtual_environment_firewall_options" "sandbox_firewall_policy" {
  node_name     = local.node_name
  vm_id         = local.vm_id
  dhcp          = true
  enabled       = true
  ipfilter      = false
  log_level_in  = "alert"
  log_level_out = "alert"
  macfilter     = false
  ndp           = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  radv          = true
  depends_on    = [proxmox_virtual_environment_vm.sandbox_instance]
}

resource "proxmox_virtual_environment_firewall_rules" "sandbox_default" {
  node_name = local.node_name
  vm_id     = local.vm_id
  ######################
  ### Inbound Rules ###
  ######################
  rule {
    security_group = local.sg_vmdefault
  }
  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.sandbox.name
  }

  # Default DROP Rule
  rule {
    type    = "in"
    action  = "DROP"
    comment = "inbound-default-drop"
    log     = "alert"
  }
  ######################
  ### Outbound Rules ###
  ######################
  depends_on = [proxmox_virtual_environment_vm.sandbox_instance]
}
