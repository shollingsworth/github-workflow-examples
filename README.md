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
    already configured
- `AWS_REGION`
  - The AWS Region to use all workflows in this repo will use the same AWS
    region.
