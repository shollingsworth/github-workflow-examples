locals {
  gh_repo             = "github-workflow-examples"
  gh_org              = "shollingsworth"
  gh_scratch_prefix   = "github-scratch"
  gh_scratch_bucket   = "${local.gh_repo}-shared"
  codeartifact_domain = local.gh_org
  ecr_repo_name       = "${local.gh_repo}-docker"
  source_control      = "https://github.com/shollingsworth/github-workflow-examples/tree/main/terraform"
  owner               = "hollingsworth.stevend@gmail.com"
}
