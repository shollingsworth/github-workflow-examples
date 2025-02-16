data "aws_iam_policy_document" "gha-demo-oidc" {
  # Allow role to use s3 as a cache

  # list base prefixes
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.github-scratch.arn
    ]

    # only allow these prefixes
    condition {
      # these are only equals, they allow
      # the action to transverse specific prefixes while allowing the
      # list objects operatons to work
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        "",
        "tests",
        "tests/",
        "deploy_artifacts",
        "deploy_artifacts/",
      ]
    }

  }

  # list all inside prefixes
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.github-scratch.arn
    ]

    condition {
      # these are globs
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "deploy_artifacts/*",
        "tests/*",
      ]
    }
  }

  # read only
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.github-scratch.arn
    ]
  }

  # r/w
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.github-scratch.arn}/deploy_artifacts/*"
    ]
  }

  # Allow ECR Operations
  statement {
    effect = "Allow"
    actions = [
      "ecr:ListImages"
    ]
    resources = [
      aws_ecr_repository.repo.arn
    ]
  }

  # allow read/write to repos
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeImageScanFindings",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      aws_ecr_repository.repo.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  # Code artifact
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sts:GetServiceBearerToken",
    ]
    condition {
      test     = "StringEquals"
      variable = "sts:AWSServiceName"
      values = [
        "codeartifact.amazonaws.com",
      ]
    }
    condition {
      test     = "NumericLessThanEquals"
      variable = "sts:DurationSeconds"
      values = [
        # keep duration at or under 30 minutes
        "1800",
      ]
    }
    resources = [
      "*"
    ]
  }

  # Allow Readonly ops to all codeartifact repos
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:Describe*",
      "codeartifact:List*",
      "codeartifact:ReadFromRepository",
      "codeartifact:GetPackageVersionAsset",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:GetRepositoryEndpoint",
    ]
    resources = [
      "*"
    ]
  }

  # Allow ReadWrite to specific packages
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:DeletePackageVersions",
      "codeartifact:DisposePackageVersions",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:PutPackageOriginConfiguration",
      "codeartifact:UpdatePackageVersionStatus",
    ]
    resources = [
      aws_codeartifact_repository.python_package.arn,
    ]
  }
}


module "gha-demo-oidc" {
  source                   = "./modules/gh_action_role/"
  role_name                = "demo-oidc"
  gh_org                   = local.gh_org
  scratch_bucket           = local.gh_scratch_bucket
  scratch_prefix           = local.gh_scratch_prefix
  repo                     = local.gh_repo
  enable_s3_github_scratch = true
  # these can be limited see
  # https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
  subject_claims = [
    # allow all claims
    "*"
  ]
  policy_doc = data.aws_iam_policy_document.gha-demo-oidc.json
}

output "gha-demo-oidc" {
  value = {
    role       = module.gha-demo-oidc.role_arn
    policy     = module.gha-demo-oidc.policy_arn
    s3_scratch = module.gha-demo-oidc.s3_scratch_location
  }
}
