#!terraform

variable aws_access_key_id {
  default     = ""
  description = "allowing you to pass this value so that the generated output can be complete"
  type        = "string"
}

variable aws_secret_access_key {
  default     = ""
  description = "allowing you to pass this value so that the generated output can be complete"
  type        = "string"
}

variable aws_s3_prefix {
  default     = ""
  description = "prefix to store charts for amazon storage backend"
  type        = "string"
}

variable aws_extra_tags {
  default     = {}
  description = "extra tags for applicable AWS resources"
}

variable kube2iam_enabled {
  default     = false
  description = "toggles configuration for kube2iam integration"
}

variable prefix {
  default     = ""
  description = "identifier to make unique resources"
  type        = "string"
}

variable force_destroy_s3_buckets {
  default = false
}
