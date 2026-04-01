# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Common Development Commands

### GCP Deployment Commands
Set required environment variables first:
```bash
cp .env.template .env
cp infra/prod.tfvars.template infra/prod.tfvars
direnv allow
```

### Infrastructure Management
Bootstrap Terraform state (one-time):
```bash
./scripts/bootstrap-tf-state.sh
```

Apply infrastructure:
```bash
cd infra
tofu init -backend-config="bucket={{GCS_BUCKET}}" -backend-config="prefix={{GCP_PROJECT_ID}}/infra"
tofu apply
```

`direnv reload` or `direnv refresh` also refreshes `GITHUB_TOKEN` from
`gh auth token` when GitHub CLI authentication is available. GitHub user
tokens expire, so rerun `gh auth login` when refresh stops yielding a token.

## Architecture Overview

### Deployment Architecture
- **Cloud Run**: Containerized deployment on Google Cloud Platform
- **Load Balancer**: Global HTTP(S) load balancer for custom domain SSL support
- **GitHub Actions CI/CD**: Automated deployment via Workload Identity Federation
- **Artifact Registry**: Container image storage
- **Infrastructure as Code**: Terraform/OpenTofu for WIF setup and IAM roles

### Infrastructure Components
The `infra/` directory contains Terraform configuration for:
- Workload Identity Pool and Provider for GitHub OIDC authentication
- Service account IAM bindings for deployment permissions
- Required project-level roles: Cloud Run admin, Artifact Registry writer, Load Balancer admin
- Global HTTP(S) Load Balancer with SSL certificates for custom domain support
- DNS zone and records for domain management
- Network Endpoint Group (NEG) connecting load balancer to Cloud Run

## Security Considerations
- Container runs as non-root user
- Uses minimal IAM permissions via dedicated service account
- Secrets managed via environment variables, not baked into images
