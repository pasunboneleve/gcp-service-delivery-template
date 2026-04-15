## Deployment Procedures

### Install dependencies

- [direnv](https://direnv.net/)
- [OpenTofu](https://opentofu.org/) or Terraform
- [GitHub CLI](https://cli.github.com/) if you want direnv to refresh `GITHUB_TOKEN`

### Set environment variables

```bash
cp .env.template .env
direnv allow
```

Define deployment values in `.env`:

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
- optional `GITHUB_TOKEN` fallback

`direnv` renders `infra/local.auto.tfvars` and
`infra/backend.auto.hcl` from those values. With direnv loaded,
`tofu plan`, `tofu apply`, `tofu destroy`, and `dress` automatically
use the generated files.
If GitHub CLI authentication is configured, `direnv allow`, `direnv reload`,
and `direnv refresh` also refresh `GITHUB_TOKEN` from `gh auth token`.
GitHub user tokens expire, so rerun `gh auth login` when refresh stops
producing a token.

### Initial Infrastructure Setup

2. **Bootstrap GCS backend** (one-time):
```bash
./scripts/bootstrap-tf-state.sh
```

3. **Initialize OpenTofu**:
```bash
cd infra
tofu init -backend-config="bucket=$GCS_BUCKET" -backend-config="prefix=$GCP_PROJECT_ID/infra"
```

4. **Apply infrastructure**:
```bash
tofu apply
```

5. **Push once to publish the bootstrap image**:
Push an application with a `Dockerfile` to `main`.

6. **Apply infrastructure again**:
```bash
tofu apply
../scripts/update-readme-live-url.sh
```

If `tofu output -raw service_url` is still empty after the first apply,
the bootstrap `latest` image does not exist in Artifact Registry yet.

### Administrative Operations

Use the dedicated admin service account for organization-level tasks:

```bash
# Organization policy management
gcloud resource-manager org-policies set-policy policy.yaml \
  --organization={ORGANIZATION_ID} \
  --impersonate-service-account=infrastructure-admin@{GCP_PROJECT_ID}.iam.gserviceaccount.com
```
