Minimal GCP Delivery Platform
=============================

This repository demonstrates a minimal delivery platform for
containerized services running on Google Cloud.

It establishes a secure and reproducible workflow for building,
testing and deploying applications using GitHub Actions,
Terraform/OpenTofu, and Google Cloud. The goal is to ensure that new
services start with a working delivery pipeline and infrastructure
layout from day one, allowing developers to focus on application logic
rather than deployment mechanics.

The template can be cloned or adapted as the starting point for a new
service repository.

---

Capabilities provided
---------------------

This repository provides a minimal internal platform capability for
service delivery:

* Secure GitHub → Google Cloud authentication using Workload Identity
  Federation (OIDC), avoiding long-lived service account keys

* Infrastructure provisioning with Terraform/OpenTofu

* Remote Terraform state stored in Google Cloud Storage with
  versioning

* Automated container build and deployment using GitHub Actions

* Container registry provisioning using Artifact Registry

* Cloud Run deployment workflow

* Standard infrastructure layout for new services

* Example BigQuery dataset provisioning

By cloning this repository, a new service immediately gains a working
delivery pipeline and secure cloud authentication model.

---

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
Deploy to Cloud Run
```

Infrastructure required for this workflow is provisioned using
Terraform/OpenTofu.

---

Repository structure
--------------------

### Top level

- `scripts/bootstrap-tf-state.sh` Creates and hardens a Google Cloud
  Storage bucket used for Terraform/OpenTofu remote state.

- `.github/workflows/deploy.yml` GitHub Actions workflow that
  authenticates to Google Cloud using OIDC, builds a container image,
  pushes it to Artifact Registry, and deploys it to Cloud Run.

- `.env.template` and `.envrc` Local developer environment
  configuration using direnv.

---

### `infra/`

Contains infrastructure definitions and deployment documentation.

Main files include:

- `main.tf` – core Google Cloud infrastructure

- `variables.tf` – required configuration inputs

- `providers.tf` – provider configuration

- `versions.tf` – Terraform/OpenTofu version constraints

- `backend.tf` – remote state configuration

- `outputs.tf` – useful outputs such as service account identities

- `github_secrets.tf` – GitHub Actions secrets managed through
  Terraform

- `bigquery.tf` – example dataset provisioning

- `DEPLOYMENT.md` – step-by-step deployment instructions

---

Bootstrapping a new project
---------------------------

Typical setup process:

1. Create or select a Google Cloud project.

2. Create a Terraform/OpenTofu state bucket:

```bash
scripts/bootstrap-tf-state.sh
```

3. Initialize Terraform/OpenTofu in the `infra/` directory.

4. Create a `.tfvars` file based on the provided template and
   configure:

    - project ID

    - project number

    - region

    - GitHub repository

    - service configuration

5. Copy `deploy.env.template` to `deploy.env` in the repository root,
   update the values, and commit `deploy.env` to the repository.

6. Apply the infrastructure:

```bash
terraform apply
```

7. Add application source code and a `Dockerfile` to the repository.

8. Push to `main`.

The GitHub Actions workflow will build the container image and deploy
it to Cloud Run.

---

Assumptions
-----------

This template assumes:

- application code and Dockerfile live in the repository root

- deployment targets Google Cloud Run

- GitHub Actions is used as the CI/CD system

- authentication to Google Cloud uses OIDC via Workload Identity
  Federation

- Terraform/OpenTofu manages infrastructure

---

Scope
-----
This repository is intentionally minimal.

It focuses on establishing the core delivery pipeline and secure
authentication model required to deploy containerized services to
Google Cloud.

Additional concerns such as load balancing, DNS configuration, service
meshes, or multi-environment deployment can be layered on top of this
foundation as required.

---

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

### Minimal but extensible

The template intentionally provisions only the resources required for
a basic delivery pipeline. Additional capabilities such as load
balancing, DNS, or multiple environments can be layered on later.

---

License

MIT

---
