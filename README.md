# Github Workflow / Action Example Repository

My Github action experiments and testing

# Repository Required Settings

## Repository Secrets

Navigate to Secrets and variables -> Actions -> Secrets (tab) -> Repository Secrets

Set The following values:

- `SLACK_WEBHOOK`
  - your destination slack channel see these [instructions](https://api.slack.com/messaging/webhooks)

## Repository Variables

Navigate to Secrets and variables -> Actions -> Variables (tab) -> Repository variables

Set The following values:

- `AWS_ROLE`
  - The AWS Role to use, this is setup in the `terraform` directory, or use one
    already configured.
    - This can be found in the terraform outputs
- `AWS_REGION`
  - The AWS Region to use all workflows in this repo will use the same AWS
    region.
- `AWS_ECR_REPO_ARN`
  - Our Demo AWS ECR Repository resource ARN
  - This can be found in the terraform outputs
- `PYTHON_PACKAGE_NAME`
  - Name of the codeartifact package repository we can write to
  - This can be found in the terraform outputs

# Terraform

## Terraform output example

```
codeartifact = {
  "base_arn" = "arn:aws:codeartifact:us-east-2:111111111111:repository/shollingsworth/shollingsworth-private"
  "base_repo" = "shollingsworth-private"
  "package_repo_arn" = "arn:aws:codeartifact:us-east-2:111111111111:repository/shollingsworth/github-workflow-examples-python"
  "package_repo_name" = "github-workflow-examples-python"
}
gha-demo-oidc = {
  "policy" = "arn:aws:iam::111111111111:policy/gha-shollingsworth-github-workflow-examples-demo-oidc"
  "role" = "arn:aws:iam::111111111111:role/gha-shollingsworth-github-workflow-examples-demo-oidc"
  "s3_scratch" = "s3://github-workflow-examples-shared/github-scratch/github-workflow-examples/demo-oidc"
}
repo_arn = "arn:aws:ecr:us-east-2:111111111111:repository/github-workflow-examples-docker"
```
