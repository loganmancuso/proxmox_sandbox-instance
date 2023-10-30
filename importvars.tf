##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

data "terraform_remote_state" "datacenter_infrastructure" {
  backend = "local"
  config = {
    path = "../datacenter-infrastructure/terraform.tfstate.d/prod/terraform.tfstate"
  }
}

locals {
  operations_user          = data.terraform_remote_state.datacenter_infrastructure.outputs.operations_user
  operations_user_password = data.terraform_remote_state.datacenter_infrastructure.outputs.operations_user_password
  instance_credentials     = data.terraform_remote_state.datacenter_infrastructure.outputs.instance_credentials
  available_nodes          = data.terraform_remote_state.datacenter_infrastructure.outputs.available_nodes
  dc_endpoint              = data.terraform_remote_state.datacenter_infrastructure.outputs.dc_endpoint
  root_password            = data.terraform_remote_state.datacenter_infrastructure.outputs.root_password
  private_network_id       = data.terraform_remote_state.datacenter_infrastructure.outputs.private_network_id
  vpc_network_id           = data.terraform_remote_state.datacenter_infrastructure.outputs.vpc_network_id
  iot_network_id           = data.terraform_remote_state.datacenter_infrastructure.outputs.iot_network_id
  sg_vmdefault             = data.terraform_remote_state.datacenter_infrastructure.outputs.sg_vmdefault
}
