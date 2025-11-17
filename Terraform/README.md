# Azure Terraform Infrastructure

This Terraform configuration provides a modular approach to deploying Azure infrastructure for client environments.

## Structure

```
Terraform/
├── foundations/            # Foundation infrastructure
│   ├── main.tf                 # Root module configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── terraform.tfvars.example # Example variable values
│   ├── providers.tf            # Provider configuration
│   └── modules/                # Reusable modules
│       ├── resource-group/
│       ├── networking/
│       ├── virtual-machine/
│       ├── storage/
│       ├── database/
│       └── app-service/
└── environments/           # Environment-specific configs (optional)
    ├── dev/
    ├── staging/
    └── prod/
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI installed and authenticated
- Azure subscription

## Usage

1. Navigate to foundations: `cd Terraform/foundations`
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Update variables with your client-specific values
4. Initialize Terraform: `terraform init`
5. Plan deployment: `terraform plan`
6. Apply configuration: `terraform apply`

## Modules

- **resource-group**: Creates Azure resource groups
- **networking**: VNet, subnets, NSGs, and network security
- **virtual-machine**: Linux/Windows VMs with managed disks
- **storage**: Storage accounts and containers
- **database**: Azure SQL Database or MySQL
- **app-service**: App Service plans and web apps
