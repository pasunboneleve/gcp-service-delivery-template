Minimal GCP Delivery Platform
=============================

Live URL
--------

<!-- LIVE_URL_START -->
- Service URL: `TODO`
<!-- LIVE_URL_END -->

This repository defines a minimal, opinionated delivery platform for
containerized services running on Google Cloud.

It establishes a secure, reproducible path from commit to production
using GitHub Actions, Terraform/OpenTofu, and Cloud Run. New services
start with a working delivery pipeline, infrastructure baseline, and
authentication model from day one — allowing developers to focus on
application logic rather than platform setup.

This is not just a template, but a small, intentional "paved road" for
service delivery. It encodes the minimum viable platform required to
deploy production services without unnecessary complexity.

The repository can be cloned or adapted as the starting point for a new
service.

⚠️ Important: CI/CD requires project setup
---------------------------------------

This repository is a template and is not connected to a live Google Cloud
project by default.

As a result, the GitHub Actions workflow will fail until:

- Workload Identity Federation is configured
- Required GitHub Actions variables are configured
- Terraform has been applied to provision infrastructure

This is expected.

Follow the bootstrapping steps below to activate the delivery pipeline.

Capabilities provided
---------------------

This repository provides a minimal internal platform capability for
service delivery:

- Secure GitHub → Google Cloud authentication using Workload Identity
  Federation (OIDC), avoiding long-lived service account keys
- Infrastructure provisioning with Terraform/OpenTofu
- Remote Terraform state stored in Google Cloud Storage with
  versioning
- Automated container build and deployment using GitHub Actions
- Container registry provisioning using Artifact Registry
- Terraform-managed Cloud Run service with GitHub Actions image updates
- Standard infrastructure layout for new services
- Example BigQuery dataset provisioning

By cloning this repository, a new service gains a reproducible path to a
working delivery pipeline and secure cloud authentication model.

Architecture overview
---------------------

Typical deployment flow:

```
Developer push
      │
      ▼
GitHub Actions workflow
      │
      ▼
OIDC authentication to Google Cloud
      │
      ▼
Build container image
      │
      ▼
Push to Artifact Registry
      │
      ▼
Update Cloud Run service
```

Infrastructure required for this workflow is provisioned using
Terraform/OpenTofu.

Repository structure
--------------------

### Top level

- `scripts/bootstrap-tf-state.sh` Creates and hardens a Google Cloud
  Storage bucket used for Terraform/OpenTofu remote state.

- `.github/workflows/deploy.yml` GitHub Actions workflow that
  authenticates to Google Cloud using OIDC, builds a container image,
  pushes it to Artifact Registry, and updates the existing Cloud Run
  service.

- `.env.template` and `.envrc` Local developer environment
  configuration using direnv. `.env` is the local source of truth for
  Terraform inputs and backend settings; `.envrc` exports Terraform
  variables and renders backend config from it.

- `scripts/check-artifact-registry-image.sh` Checks whether the bootstrap
  image tag exists so Terraform knows if it can create the Cloud Run
  service yet.

- `scripts/update-readme-live-url.sh` Updates the live URL block from
  `tofu output`.

### `infra/`

Contains infrastructure definitions and deployment documentation.

Main files include:

- `main.tf` – core Google Cloud infrastructure
- `variables.tf` – required configuration inputs
- `providers.tf` – provider configuration
- `versions.tf` – Terraform/OpenTofu version constraints
- `backend.tf` – remote state configuration
- `outputs.tf` – useful outputs such as service account identities
- `github_secrets.tf` – GitHub Actions variables managed through
  Terraform
- `bigquery.tf` – example dataset provisioning
- `DEPLOYMENT.md` – step-by-step deployment instructions

Bootstrapping a new project
---------------------------

Typical setup process:

1. Create or select a Google Cloud project.

2. Create a Terraform/OpenTofu state bucket:

```bash
scripts/bootstrap-tf-state.sh
```

3. Initialize Terraform/OpenTofu in the `infra/` directory.

4. Copy the local environment template:

```bash
cp .env.template .env
direnv allow
```

5. Update `.env` with deployment values:

   - `GCP_OWNER`
   - `GCP_PROJECT_ID`
   - `GCP_PROJECT_NUMBER`
   - `GCP_REGION`
   - `GCS_BUCKET`
   - `GCP_REPOSITORY_ID`
   - `GCP_WORKLOAD_IDENTITY_POOL`
   - `GCP_WORKLOAD_IDENTITY_PROVIDER`
   - `GCP_SERVICE_NAME`
   - `GITHUB_OWNER`
   - `GITHUB_REPO`
   - optional `GITHUB_TOKEN` fallback if you do not use `gh auth login`

   `direnv` exports these values as `TF_VAR_*` variables and renders
   `infra/backend.auto.hcl` automatically.

6. Apply the infrastructure:

```bash
tofu apply
```

With `direnv` loaded, `tofu plan`, `tofu apply`, `tofu destroy`, and
`dress` automatically use Terraform input values from the environment and
backend config derived from `.env`.
If GitHub CLI authentication is configured, `direnv allow`, `direnv reload`,
and `direnv refresh` also refresh `GITHUB_TOKEN` from `gh auth token`.
GitHub user tokens expire, so rerun `gh auth login` if the refresh stops
producing a token.

8. Add application source code and a `Dockerfile` to the repository.

9. Push to `main` once so GitHub Actions publishes the bootstrap `latest`
   image to Artifact Registry.

10. Run `tofu apply` again so Terraform can create the Cloud Run service
    from that image.

11. Refresh the README live URL block:

```bash
./scripts/update-readme-live-url.sh
```

The GitHub Actions workflow will build the container image, push it to
Artifact Registry, and update the Terraform-managed Cloud Run service.
If `tofu output -raw service_url` is still empty after the first apply,
the bootstrap image does not exist in Artifact Registry yet. Push once,
rerun `tofu apply`, then update the README.

Assumptions
-----------

This template assumes:

- application code and Dockerfile live in the repository root
- deployment targets Google Cloud Run
- GitHub Actions is used as the CI/CD system
- authentication to Google Cloud uses OIDC via Workload Identity
  Federation
- Terraform/OpenTofu manages infrastructure
- local deployment settings come from `.env`
- Terraform inputs come from `TF_VAR_*` exported by `.envrc`
- backend config comes from `infra/backend.auto.hcl`

Scope
-----

This repository is intentionally minimal.

It defines the smallest viable platform required to securely build,
deploy, and run containerized services on Google Cloud.

The goal is to provide a complete and production-usable delivery path
without introducing platform complexity prematurely.

Concerns such as load balancing, DNS, multi-environment promotion, or
service mesh are deliberately excluded and can be layered on top as
needed.

Design principles
-----------------

This template follows a few principles that help keep delivery
infrastructure simple and secure.

### Infrastructure as code

All cloud resources are provisioned through Terraform/OpenTofu so that
infrastructure changes are versioned, reviewable, and reproducible.

### Short-lived credentials

GitHub Actions authenticates to Google Cloud using Workload Identity
Federation. This avoids storing long-lived service account keys in CI
systems.

### Bootstrap early

A working deployment pipeline should exist at the start of a project
rather than being added later. This reduces friction as the system
grows.

### Minimal by design, extensible by necessity

The template provisions only the capabilities required for a working
delivery pipeline. Additional concerns should be introduced when they
are needed, not before.

---

License: MIT
