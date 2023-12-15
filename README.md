# Terraform Proxmox

This workflow deploys a test instance on proxmox, it depends on the existing template vm 

##### Dependancies
- loganmancuso_infrastructure/applications/hashicorp-vault>
- loganmancuso_infrastructure/proxmox/datacenter-infrastructure>
- loganmancuso_infrastructure/proxmox/vault-infrastructure>
- loganmancuso_infrastructure/proxmox/global-secrets>
- loganmancuso_infrastructure/proxmox/packer-vm-templates>

## Deployment
to deploy this workflow link the environment tfvars folder to the root directory. 
```bash
  ln -s env/* .
  tofu init .
  tofu plan
  tofu apply
```