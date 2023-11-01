##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

data "terraform_remote_state" "datacenter_infrastructure" {
  backend = "http"
  config = {
    address  = "https://gitlab.com/api/v4/projects/48634510/terraform/state/bytevault"
    username = "loganmancuso"
  }
}

data "terraform_remote_state" "packer_vm_template" {
  backend = "http"
  config = {
    address  = "https://gitlab.com/api/v4/projects/48496137/terraform/state/jammy-2204"
    username = "loganmancuso"
  }
}

locals {
  # datacenter_infrastructure
  node_name          = data.terraform_remote_state.datacenter_infrastructure.outputs.node_name
  node_ip            = data.terraform_remote_state.datacenter_infrastructure.outputs.node_ip
  private_network_id = data.terraform_remote_state.datacenter_infrastructure.outputs.private_network_id
  vpc_network_id     = data.terraform_remote_state.datacenter_infrastructure.outputs.vpc_network_id
  iot_network_id     = data.terraform_remote_state.datacenter_infrastructure.outputs.iot_network_id
  sg_vmdefault       = data.terraform_remote_state.datacenter_infrastructure.outputs.sg_vmdefault
  # packer_vm_template
  instance_username        = data.terraform_remote_state.packer_vm_template.outputs.instance_username
  instance_password_hashed = data.terraform_remote_state.packer_vm_template.outputs.instance_password_hashed
  instance_ssh_pubkey      = data.terraform_remote_state.packer_vm_template.outputs.instance_ssh_pubkey
  vm_template_id           = data.terraform_remote_state.packer_vm_template.outputs.vm_template_id
}
