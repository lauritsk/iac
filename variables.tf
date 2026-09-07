variable "incus_remote" {
  description = "Incus client remote that points at the homelab server"
  type        = string
  default     = "hv01"
}

variable "beszel_user_email" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "beszel_user_password" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "beszel_agent_token" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "beszel_agent_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "bichon_encrypt_password" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "immich_db_name" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "immich_db_username" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "immich_db_password" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "prowlarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "radarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "sonarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "dev_tailscale_authkey" {
  type      = string
  sensitive = true
  nullable  = false

  validation {
    condition     = length(trimspace(var.dev_tailscale_authkey)) > 0
    error_message = "The dev Tailscale auth key must not be empty."
  }
}

variable "tailscale_oauth_secret" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "tsidp_oauth_secret" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "transmission_username" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "transmission_password" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "zerobyte_app_secret" {
  type      = string
  sensitive = true
  nullable  = false
}
