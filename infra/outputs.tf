output "workload_identity_pool_name" {
  value = local.wif_pool_name
}

output "workload_identity_provider_name" {
  value = local.wif_provider_name
}

output "impersonated_service_account" {
  value = google_service_account.github_actions.email
}

output "admin_service_account" {
  value = google_service_account.admin.email
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository name used for Cloud Run images."
  value       = google_artifact_registry_repository.images.name
}

output "cloud_run_service_name" {
  description = "Name of the Terraform-managed Cloud Run service."
  value       = try(google_cloud_run_v2_service.service[0].name, null)
}

output "service_url" {
  description = "Public Cloud Run service URL."
  value       = try(google_cloud_run_v2_service.service[0].uri, null)
}
