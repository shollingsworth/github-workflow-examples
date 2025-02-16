variable "role_name" {
  description = "role name suffix"
  type        = string
  nullable    = false
}

variable "gh_org" {
  description = "github organization"
  type        = string
  nullable    = false
}

variable "scratch_bucket" {
  description = "aws profile"
  type        = string
  nullable    = false
}

variable "scratch_prefix" {
  description = "aws profile"
  type        = string
  nullable    = false
}

variable "repo" {
  description = "repo slug i.e. useful-code-bits"
  type        = string
  nullable    = false
}

variable "subject_claims" {
  description = "see: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims"
  type        = list(string)
  nullable    = false
}

variable "max_session_duration_seconds" {
  description = "maximum duration of the session in seconds"
  type        = number
  default     = 3600 # 1 hr
}

variable "policy_doc" {
  description = "policy doc json defined outside of this module"
  type        = string
}

variable "enable_s3_github_scratch" {
  description = "Enable github scratch s3 location s3://{var.scratch_bucket}/{local.s3_scratch_prefix}/*"
  type        = bool
  default     = false
}
