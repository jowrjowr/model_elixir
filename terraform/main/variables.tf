# nixos configuration

variable "nixos_version" {
  description = "what specific version to use"
  default     = "NixOS-22.05.342.a634c8f6c1f-x86_64-linux"
}

variable "deletion_protection" {
  description = "protect assets from accidental purging?"
  default     = false
}

variable "maintenance_window" {
  description = "when AWS maintenance can occur (UTC)"
  default     = "Mon:03:00-Mon:05:00"
}

variable "apply_immediately" {
  description = "whether to do disruptive things NOW"
  default     = true
}

variable "lb_alarms" {
  description = "whether they are enabled or not"
  default     = true
  type        = bool
}

# database configuration

variable "database_multi_az" {
  description = "database multi az redundancy"
  default     = false
}

variable "database_backup_retention" {
  description = "backup retention time"
  default     = 0
}

variable "database_instance" {
  description = "database instance type"
}

variable "api_instance" {
  description = "api API instance type"
}

variable "database_storage_type" {
  default = "gp2"
}

variable "database_allocated_storage" {
  description = "how much storage in GB to start with"
  default     = "10"
}

variable "database_iops" {
  description = "database reserved iops - overrides database_storage_type by setting"
  default     = 0
}

# local environment-specific

variable "key_name" {
  description = "AWS keypair"
}

variable "environment" {
  description = "environment name"
}
variable "binary_cache_public_key" {
  default = "../../../nix/keys/key.public"
}
