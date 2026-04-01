# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Issue Tracking

This project uses **bd (beads)** for issue tracking.
Run `bd prime` for workflow context.

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

After the first push publishes the bootstrap `latest` image, rerun
`tofu apply` so Terraform can create the Cloud Run service and expose its
URL via `tofu output`.

`direnv reload` or `direnv refresh` also refreshes `GITHUB_TOKEN` from
`gh auth token` when GitHub CLI authentication is available. GitHub user
tokens expire, so rerun `gh auth login` when refresh stops yielding a token.

## Architecture Overview

### Deployment Architecture
- **Cloud Run**: Containerized deployment on Google Cloud Platform
- **Load Balancer**: Global HTTP(S) load balancer for custom domain SSL support
- **GitHub Actions CI/CD**: Automated image publishing and Cloud Run updates via Workload Identity Federation
- **Artifact Registry**: Container image storage
- **Infrastructure as Code**: Terraform/OpenTofu for WIF setup and IAM roles

### Infrastructure Components
The `infra/` directory contains Terraform configuration for:
- Workload Identity Pool and Provider for GitHub OIDC authentication
- Service account IAM bindings for deployment permissions
- Required project-level roles for CI: Cloud Run admin and Artifact Registry writer
- Cloud Run service provisioning once the bootstrap image exists in Artifact Registry
- Global HTTP(S) Load Balancer with SSL certificates for custom domain support
- DNS zone and records for domain management
- Network Endpoint Group (NEG) connecting load balancer to Cloud Run

## Security Considerations
- Container runs as non-root user
- Uses minimal IAM permissions via dedicated service account
- Secrets managed via environment variables, not baked into images

## Session Completion

When work needs follow-up:

1. Create or update the relevant bead.
2. Run the appropriate quality checks.
3. Run `bd sync` if bead data changed.
4. Commit the repository changes.
5. Do not push unless the user explicitly asks for it.
