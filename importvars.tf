##############################################################################
#
# Author: Logan Mancuso
# Created: 11.28.2023
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


data "terraform_remote_state" "global_secrets" {
  backend = "http"
  config = {
    address  = "https://gitlab.com/api/v4/projects/52104036/terraform/state/global-secrets"
    username = "loganmancuso"
  }
}

data "terraform_remote_state" "vault_infrastructure" {
  backend = "http"
  config = {
    address  = "https://gitlab.com/api/v4/projects/52104036/terraform/state/vault-infrastructure"
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
  vm_template_id           = data.terraform_remote_state.packer_vm_template.outputs.vm_template_id
  default_tags             = data.terraform_remote_state.packer_vm_template.outputs.default_tags
  # global_secrets
  vault_shared_instance_credentials = data.terraform_remote_state.global_secrets.outputs.vault_shared_instance_credentials
  # vault_infrastructure
  vault_shared_path = data.terraform_remote_state.vault_infrastructure.outputs.vault_shared_path
  vault_infra_path  = data.terraform_remote_state.vault_infrastructure.outputs.vault_infra_path
  vault_app_path    = data.terraform_remote_state.vault_infrastructure.outputs.vault_app_path
}

## Obtain Vault Secrets ##

data "vault_kv_secret_v2" "instance_credentials" {
  mount = local.vault_shared_path
  name  = local.vault_shared_instance_credentials
}

locals {
  secret_instance_credentials = nonsensitive(jsondecode(data.vault_kv_secret_v2.instance_credentials.data_json))
}