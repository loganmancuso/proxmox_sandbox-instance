# Terraform Proxmox

This workflow deploys a test instance on proxmox, it depends on the existing template vm deployed by the packer workflow

##### Dependancies
- loganmancuso_infrastructure/proxmox/datacenter-infrastructure>
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

#### Special Thanks:
This [project](https://github.com/bpg/terraform-provider-proxmox/tree/main) has been a huge foundation on which to build this automation, please consider sponsoring [Pavel Boldyrev](https://github.com/bpg)