variable "buckets" {
  description = "List of buckets to create"
  type        = list(string)
}

variable "user_readonly_permissions" {
  description = "List of users and their access to buckets"
  type        = map(list(string))
}

variable "user_readwrite_permissions" {
  description = "List of users and their access to buckets"
  type        = map(list(string))
}
