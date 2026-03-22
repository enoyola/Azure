# Azure Infrastructure Repository

This repository groups Azure infrastructure code, operational automation, and governance artifacts used to build and manage client environments.

The current focus of the repository is:

- Terraform blueprints for reusable Azure infrastructure
- Network architecture examples, including a hub-and-spoke topology
- PowerShell runbooks for day-2 Azure operations
- ARM-based policy and tagging definitions

## Repository Contents

### Terraform

The [Terraform](./Terraform) directory contains modular Azure infrastructure projects.

- [Terraform/foundations](./Terraform/foundations) provisions a baseline environment with resource groups, networking, storage, virtual machines, databases, and App Service.
- [Terraform/hub-and-spoke](./Terraform/hub-and-spoke) provisions a hub-and-spoke network topology with shared services such as Azure Firewall, Bastion, VPN Gateway, and VNet peering.

Both Terraform projects now follow a CAF-style resource naming approach where the resource type abbreviation appears at the beginning of the name.

### PowerShell Runbooks

The [PowerShell - Runbooks](./PowerShell%20-%20Runbooks) directory contains Azure administration scripts and Automation-style runbooks, including:

- VM start, stop, and restart operations
- Disk copy workflows across regions
- Backup and restore helpers
- MySQL start and stop automation
- VMware migration support scripts

There is also a `v1-basic` subfolder with older or simplified runbook variants.

### Policy And Tagging Templates

The repository root includes ARM JSON templates for Azure governance scenarios:

- [MultipleTags.json](./MultipleTags.json) defines and assigns a custom policy that enforces or adds multiple tags.
- [Definition Tags- CreatedOnDate.json](./Definition%20Tags-%20CreatedOnDate.json) defines and assigns a tag policy for date stamping resources.

## Structure

```text
Azure/
├── Terraform/
│   ├── foundations/
│   ├── hub-and-spoke/
│   └── README.md
├── PowerShell - Runbooks/
│   ├── v1-basic/
│   └── *.ps1
├── MultipleTags.json
├── Definition Tags- CreatedOnDate.json
└── README.md
```

## Terraform Projects

### Foundations

Use the foundations project when you need a starting point for an application or client landing zone with common Azure services.

Main capabilities:

- Resource group creation
- Virtual network, subnets, and NSGs
- Storage account and containers
- Optional virtual machine deployment
- Optional database deployment
- Optional App Service deployment

Start here:

- [Terraform/foundations/main.tf](./Terraform/foundations/main.tf)
- [Terraform/foundations/variables.tf](./Terraform/foundations/variables.tf)
- [Terraform/foundations/terraform.tfvars.example](./Terraform/foundations/terraform.tfvars.example)

### Hub-And-Spoke

Use the hub-and-spoke project when you need a more opinionated network topology with centralized shared services and segmented workload networks.

Main capabilities:

- Hub VNet with shared infrastructure
- Multiple spoke VNets
- VNet peering between hub and spokes
- Optional Azure Firewall
- Optional Azure Bastion
- Optional VPN Gateway

Start here:

- [Terraform/hub-and-spoke/main.tf](./Terraform/hub-and-spoke/main.tf)
- [Terraform/hub-and-spoke/variables.tf](./Terraform/hub-and-spoke/variables.tf)
- [Terraform/hub-and-spoke/terraform.tfvars.example](./Terraform/hub-and-spoke/terraform.tfvars.example)

## Quick Start

### Terraform

1. Choose a project under `Terraform/`.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`.
3. Update values such as client name, environment, location, and feature toggles.
4. Run `terraform init`.
5. Run `terraform plan`.
6. Run `terraform apply`.

### PowerShell

1. Review the target script in `PowerShell - Runbooks/`.
2. Confirm the required Az modules and Azure permissions.
3. Test in a non-production subscription or automation account first.

## Requirements

- Terraform 1.x
- Azure CLI authenticated to the target subscription
- An Azure subscription with permissions to deploy infrastructure
- PowerShell with the Az modules for runbook execution

## Notes

- Terraform module validation may require `terraform init` inside each project directory before `terraform validate`.
- Some Azure resources have naming restrictions that differ from general CAF examples. The Terraform code in this repository handles those cases where needed, such as storage account naming and reserved subnet names.
- Project-specific details remain in the nested READMEs under [Terraform](./Terraform).
