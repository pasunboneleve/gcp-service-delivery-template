## Deployment Procedures

### Install dependencies

- [direnv](https://direnv.net/)
- [OpenTofu](https://opentofu.org/) or Terraform
- [GitHub CLI](https://cli.github.com/) if you want direnv to refresh `GITHUB_TOKEN`

### Set environment variables

```bash
cp .env.template .env
cp infra/prod.tfvars.template infra/prod.tfvars
direnv allow
```

Define local shell-only values in `.env`:

- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCS_BUCKET`
- optional `GITHUB_TOKEN` fallback

Define Terraform inputs in `infra/prod.tfvars`:

- `gcp_owner`
- `repository_id`
- `project_id`
- `project_number`
- `region`
- `pool_id`
- `provider_id`
- `service_name`
- `container_port`
- `github_owner`
- `github_repo`

With direnv loaded, `tofu plan`, `tofu apply`, and `tofu destroy`
automatically use `infra/prod.tfvars`.
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
