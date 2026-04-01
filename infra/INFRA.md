# Infrastructure (OpenTofu/Terraform)

This folder provisions:
- Workload Identity Pool and Provider for GitHub OIDC
- IAM binding to let your GitHub repo impersonate the deploy service account
- Project roles for the deploy service account (Cloud Run, Artifact Registry, Cloud Build)
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
Copy `prod.tfvars.template` to `prod.tfvars` and set values matching your
environment:
```bash
cp prod.tfvars.template prod.tfvars
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

`direnv` is expected to export `TF_CLI_ARGS_plan`, `TF_CLI_ARGS_apply`,
and `TF_CLI_ARGS_destroy` so `tofu` automatically uses `infra/prod.tfvars`.
If GitHub CLI authentication is configured, `direnv allow`, `direnv reload`,
and `direnv refresh` also refresh `GITHUB_TOKEN` from `gh auth token`.
GitHub user tokens expire, so rerun `gh auth login` when refresh stops
producing a token.
