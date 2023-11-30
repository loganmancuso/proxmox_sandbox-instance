# Terraform Proxmox

This workflow deploys a test instance on proxmox, it depends on the existing template vm 

## Usage
to deploy this workflow link the environment tfvars folder to the root directory. 
```
  ln -s env/* .
  tofu init .
  tofu plan
  tofu apply
```