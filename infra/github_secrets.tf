# GitHub Actions variables
# These values are automatically configured for the deploy workflow.

resource "github_actions_variable" "gcp_project_id" {
  repository    = var.github_repo
  variable_name = "GCP_PROJECT_ID"
  value         = var.project_id
}

resource "github_actions_variable" "gcp_project_number" {
  repository    = var.github_repo
  variable_name = "GCP_PROJECT_NUMBER"
  value         = var.project_number
}

resource "github_actions_variable" "gcp_region" {
  repository    = var.github_repo
  variable_name = "GCP_REGION"
  value         = var.region
}

resource "github_actions_variable" "gcp_workload_identity_pool" {
  repository    = var.github_repo
  variable_name = "GCP_WORKLOAD_IDENTITY_POOL"
  value         = var.pool_id
}

resource "github_actions_variable" "gcp_workload_identity_provider" {
  repository    = var.github_repo
  variable_name = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  value         = var.provider_id
}

resource "github_actions_variable" "gcp_service_account" {
  repository    = var.github_repo
  variable_name = "GCP_SERVICE_ACCOUNT"
  value         = google_service_account.github_actions.email
}

resource "github_actions_variable" "gcp_service_name" {
  repository    = var.github_repo
  variable_name = "GCP_SERVICE_NAME"
  value         = var.service_name
}

resource "github_actions_variable" "gcp_repo" {
  repository    = var.github_repo
  variable_name = "GCP_REPO"
  value         = var.repository_id
}
