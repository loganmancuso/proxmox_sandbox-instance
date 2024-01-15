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
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.37.0"
    }
  }
  backend "http" {
    address  = "https://gitlab.com/api/v4/projects/48496137/terraform/state/sandbox-instance"
    username = "loganmancuso"
  }
}

provider "proxmox" {
  endpoint = "https://${local.node_ip}:8006/"
  username = "root@pam"
  password = local.credentials_proxmox.root_password
  # (Optional) Skip TLS Verification
  insecure = true
  ssh {
    agent    = true
    username = "root"
    node {
      name    = local.node_name
      address = local.node_ip
    }
  }
}