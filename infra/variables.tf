variable "gcp_owner" {
  description = "GCP owner's email"
  type        = string
}

variable "repository_id" {
  description = "GCP repository ID"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "project_number" {
  description = "GCP project number"
  type        = string
}

variable "region" {
  description = "Default region for APIs that require one"
  type        = string
}

variable "pool_id" {
  description = "Workload Identity Pool ID (e.g., github-pool)"
  type        = string
}

variable "provider_id" {
  description = "Workload Identity Provider ID (e.g., github-provider)"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name used by the deploy workflow"
  type        = string
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 8080
}

variable "cloud_run_image_tag" {
  description = "Container image tag Terraform should use when creating or recreating the Cloud Run service."
  type        = string
  default     = "latest"
}

variable "github_owner" {
  description = "GitHub organization or user"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}
