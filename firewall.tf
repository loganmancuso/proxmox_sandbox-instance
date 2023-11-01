##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

resource "proxmox_virtual_environment_firewall_alias" "test" {
  name    = "test"
  cidr    = local.ip_addr
  comment = "test data server ip"
}

resource "proxmox_virtual_environment_firewall_options" "test_firewall_policy" {
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
  depends_on    = [proxmox_virtual_environment_vm.test_instance]
}

resource "proxmox_virtual_environment_firewall_rules" "test_default" {
  node_name = local.node_name
  vm_id     = local.vm_id
  ######################
  ### Inbound Rules ###
  ######################
  rule {
    security_group = local.sg_vmdefault
  }
  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.test.name
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
  depends_on = [proxmox_virtual_environment_vm.test_instance]
}
