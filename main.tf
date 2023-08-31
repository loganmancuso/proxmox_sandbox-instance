##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

#######################################
# Provider
#######################################

terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.29.0"
    }
  }
  backend "http" {
  }
}

provider "proxmox" {
  endpoint = "https://${local.dc_endpoint}:8006/"
  username = "root@pam"
  password = local.root_password
  # (Optional) Skip TLS Verification
  insecure = true
  ssh {
    agent    = true
    username = "root"
    password = local.root_password
    dynamic "node" {
      for_each = local.available_nodes
      content {
        name    = node.key
        address = node.value
      }
    }
  }
}