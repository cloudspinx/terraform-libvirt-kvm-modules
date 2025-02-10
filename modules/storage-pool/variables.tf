variable "storage_pool_name" {
  description = "The name of the storage Libvirt pool"
  type        = string
  default     = "vms_storage"
}

variable "create_storage_pool" {
  description = "Whether to create the storage Libvirt storage pool"
  type        = bool
  default     = true
}

variable "storage_pool_path" {
  description = "The path where the storage Libvirt pool will be stored"
  type        = string
  default     = "/var/lib/libvirt/images"
}
