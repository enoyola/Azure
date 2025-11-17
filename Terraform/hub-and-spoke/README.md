# Azure Hub-and-Spoke Architecture

This Terraform configuration implements a hub-and-spoke network topology in Azure, providing centralized security, connectivity, and shared services.

## Architecture Overview

The hub-and-spoke topology consists of:

- **Hub VNet**: Central network containing shared services (firewall, VPN gateway, bastion)
- **Spoke VNets**: Isolated workload networks (production, development, shared services)
- **VNet Peering**: Connects spokes to hub with controlled routing
- **Azure Firewall**: Centralized network security and traffic inspection
- **Azure Bastion**: Secure RDP/SSH access without public IPs
- **VPN Gateway**: Hybrid connectivity to on-premises networks

## Benefits

- Centralized security and monitoring
- Network isolation between workloads
- Shared services (DNS, monitoring, backup)
- Cost optimization through resource sharing
- Simplified hybrid connectivity

## Structure

```
hub-and-spoke/
├── main.tf                 # Main orchestration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── providers.tf            # Provider configuration
├── terraform.tfvars.example
└── modules/
    ├── hub-network/        # Hub VNet with shared services
    ├── spoke-network/      # Spoke VNet template
    ├── vnet-peering/       # VNet peering configuration
    ├── azure-firewall/     # Azure Firewall
    ├── bastion/            # Azure Bastion
    └── vpn-gateway/        # VPN Gateway
```

## Usage

1. Navigate to hub-and-spoke: `cd Terraform/hub-and-spoke`
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Update variables with your values
4. Initialize: `terraform init`
5. Plan: `terraform plan`
6. Apply: `terraform apply`

## Default Topology

- Hub VNet: 10.0.0.0/16
  - AzureFirewallSubnet: 10.0.1.0/26
  - AzureBastionSubnet: 10.0.2.0/26
  - GatewaySubnet: 10.0.3.0/27
  - SharedServicesSubnet: 10.0.4.0/24

- Production Spoke: 10.1.0.0/16
- Development Spoke: 10.2.0.0/16
- Shared Services Spoke: 10.3.0.0/16
