#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFRA_DIR="${ROOT_DIR}/infra"

TF_VARS_OUTPUT="${TF_VARS_OUTPUT:-${INFRA_DIR}/local.auto.tfvars}"
TF_BACKEND_CONFIG_OUTPUT="${TF_BACKEND_CONFIG_OUTPUT:-${INFRA_DIR}/backend.auto.hcl}"

require_env() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

hcl_string() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "${value}"
}

derive_github_repo_from_origin() {
  local origin_url repo_path owner repo
  origin_url="$(git -C "${ROOT_DIR}" remote get-url origin 2>/dev/null || true)"
  if [ -z "${origin_url}" ]; then
    return 0
  fi

  repo_path="${origin_url%.git}"
  repo_path="${repo_path##*:}"
  repo_path="${repo_path#https://github.com/}"
  repo_path="${repo_path#http://github.com/}"
  repo_path="${repo_path#git@github.com/}"

  owner="${repo_path%%/*}"
  repo="${repo_path##*/}"

  if [ -n "${owner}" ] && [ "${owner}" != "${repo_path}" ] && [ -z "${GITHUB_OWNER:-}" ]; then
    export GITHUB_OWNER="${owner}"
  fi

  if [ -n "${repo}" ] && [ -z "${GITHUB_REPO:-}" ]; then
    export GITHUB_REPO="${repo}"
  fi
}

if [ -z "${GITHUB_REPO:-}" ]; then
  export GITHUB_REPO="$(basename "${ROOT_DIR}")"
fi

if [ -n "${SERVICE_NAME:-}" ] && [ -z "${GCP_SERVICE_NAME:-}" ]; then
  export GCP_SERVICE_NAME="${SERVICE_NAME}"
fi

if [ -n "${GCP_ARTIFACT_REGISTRY_REPOSITORY:-}" ] && [ -z "${GCP_REPOSITORY_ID:-}" ]; then
  export GCP_REPOSITORY_ID="${GCP_ARTIFACT_REGISTRY_REPOSITORY}"
fi

if [ -n "${GITHUB_ORG:-}" ] && [ -z "${GITHUB_OWNER:-}" ]; then
  export GITHUB_OWNER="${GITHUB_ORG}"
fi

if [ -n "${GITHUB_REPOSITORY_NAME:-}" ] && [ -z "${GITHUB_REPO:-}" ]; then
  export GITHUB_REPO="${GITHUB_REPOSITORY_NAME}"
fi

if [ -n "${OWNER_EMAIL:-}" ] && [ -z "${GCP_OWNER:-}" ]; then
  export GCP_OWNER="${OWNER_EMAIL}"
fi

derive_github_repo_from_origin

require_env GCP_OWNER
require_env GCP_PROJECT_ID
require_env GCP_PROJECT_NUMBER
require_env GCP_REGION
require_env GCS_BUCKET
require_env GCP_REPOSITORY_ID
require_env GCP_WORKLOAD_IDENTITY_POOL
require_env GCP_WORKLOAD_IDENTITY_PROVIDER
require_env GCP_SERVICE_NAME
require_env GITHUB_OWNER
require_env GITHUB_REPO

mkdir -p "$(dirname "${TF_VARS_OUTPUT}")" "$(dirname "${TF_BACKEND_CONFIG_OUTPUT}")"

cat >"${TF_VARS_OUTPUT}" <<EOF
gcp_owner      = $(hcl_string "${GCP_OWNER}")
repository_id  = $(hcl_string "${GCP_REPOSITORY_ID}")
project_id     = $(hcl_string "${GCP_PROJECT_ID}")
project_number = $(hcl_string "${GCP_PROJECT_NUMBER}")
region         = $(hcl_string "${GCP_REGION}")
pool_id        = $(hcl_string "${GCP_WORKLOAD_IDENTITY_POOL}")
provider_id    = $(hcl_string "${GCP_WORKLOAD_IDENTITY_PROVIDER}")
service_name   = $(hcl_string "${GCP_SERVICE_NAME}")
container_port = ${CONTAINER_PORT:-8080}
github_owner   = $(hcl_string "${GITHUB_OWNER}")
github_repo    = $(hcl_string "${GITHUB_REPO}")
cloud_run_image_tag = $(hcl_string "${CLOUD_RUN_IMAGE_TAG:-latest}")
EOF

cat >"${TF_BACKEND_CONFIG_OUTPUT}" <<EOF
bucket = $(hcl_string "${GCS_BUCKET}")
prefix = "${GCP_PROJECT_ID}/infra"
EOF
