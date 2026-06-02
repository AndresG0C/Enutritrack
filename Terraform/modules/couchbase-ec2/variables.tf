variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "root_volume_size" {
  type    = number
  default = 50
}

variable "cluster_name" {
  type    = string
  default = "enutritrack"
}

variable "bucket_name" {
  type    = string
  default = "enutritrack"
}

variable "couchbase_username" {
  type      = string
  sensitive = true
  default   = "Admin"
}

variable "couchbase_password" {
  type      = string
  sensitive = true
  default   = "admin123"
}

variable "iam_instance_profile_name" {
  type    = string
  default = null
}

variable "assign_eip" {
  type    = bool
  default = false
}
