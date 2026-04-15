#!/usr/bin/env bash
set -euo pipefail

eval "$(jq -r '@sh "PROJECT_ID=\(.project_id) REGION=\(.region) REPOSITORY_ID=\(.repository_id) IMAGE_NAME=\(.image_name) IMAGE_TAG=\(.image_tag)"')"

IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${IMAGE_NAME}:${IMAGE_TAG}"

if output="$(gcloud artifacts docker images describe "${IMAGE_PATH}" --project "${PROJECT_ID}" 2>&1)"; then
  jq -n '{"exists":"true"}'
elif printf '%s' "${output}" | grep -Eqi 'not found|SERVICE_DISABLED|repository .* was not found'; then
  # Bootstrap applies run before Artifact Registry or its API are fully ready.
  # In that case treat the image as absent so Terraform can finish enabling
  # services and creating the repository, then create Cloud Run on a later apply.
  jq -n '{"exists":"false"}'
else
  echo "Artifact Registry check failed: ${output}" >&2
  exit 1
fi
