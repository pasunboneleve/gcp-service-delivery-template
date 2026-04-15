# Infrastructure (OpenTofu/Terraform)

This folder provisions:
- Workload Identity Pool and Provider for GitHub OIDC
- IAM binding to let your GitHub repo impersonate the deploy service account
- Least-privilege project roles for the deploy service account (Cloud Run admin and Artifact Registry writer)
- Cloud Run service creation once the bootstrap image exists in Artifact Registry

## Prereqs
- gcloud (authenticated to the target project)
- Terraform/OpenTofu 1.5+
- GitHub CLI or a `GITHUB_TOKEN` exported in your shell for the GitHub provider

## 1) Create a remote state bucket (one-time)
```bash
export GCP_PROJECT_ID=<your-project-id>
export GCS_BUCKET=<globally-unique-bucket-name>
./scripts/bootstrap-tf-state.sh
```

## 2) Init with GCS backend
```bash
cd infra
tofu init \
  -backend-config="bucket=$GCS_BUCKET" \
  -backend-config="prefix=$GCP_PROJECT_ID/infra"
```

## 3) Apply
Load `.env` through `direnv` so the repo can render local Terraform
config from environment variables:
```bash
cp ../.env.template ../.env
direnv allow
tofu apply
```

Outputs will include the WIF resource names.
Useful outputs also include:

- `artifact_registry_repository`
- `cloud_run_service_name`
- `service_url`

If `service_url` is `null`, the configured bootstrap image tag does not
exist in Artifact Registry yet. Push one image to `main`, rerun `tofu apply`,
then update the README:

```bash
../scripts/update-readme-live-url.sh
```

`direnv` renders `infra/backend.auto.hcl` and exports Terraform inputs
via `TF_VAR_*` so `tofu` and `dress` use environment-derived config by
default.
If GitHub CLI authentication is configured, `direnv allow`, `direnv reload`,
and `direnv refresh` also refresh `GITHUB_TOKEN` from `gh auth token`.
GitHub user tokens expire, so rerun `gh auth login` when refresh stops
producing a token.
