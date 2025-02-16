data "aws_iam_openid_connect_provider" "gh_idp" {
  url = "https://token.actions.githubusercontent.com"
}


data "aws_iam_policy_document" "gha_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.gh_idp.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for claim in var.subject_claims : "repo:${var.gh_org}/${var.repo}:${claim}"
      ]
    }
  }
}

data "aws_iam_policy_document" "gha_s3_scratch_policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      local.bucket_arn,
    ]

    # only software / cloud_data
    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        "",
        "${local.s3_scratch_prefix}",
        "${local.s3_scratch_prefix}/",
      ]
    }

  }

  # list all inside prefixes
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      local.bucket_arn,
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "${local.s3_scratch_prefix}/*",
      ]
    }
  }

  # r/w
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      "${local.bucket_arn}/${local.s3_scratch_prefix}/*",
    ]
  }
}

resource "aws_iam_role" "gha_oidc_assume_role" {
  name                 = "gha-${var.gh_org}-${var.repo}-${var.role_name}"
  assume_role_policy   = data.aws_iam_policy_document.gha_assume_role_policy.json
  max_session_duration = var.max_session_duration_seconds
  tags = {
    application = "github-actions"
    repo        = "${var.gh_org}/${var.repo}"
  }
}

resource "aws_iam_policy" "gha_s3_scratch_policy" {
  count  = var.enable_s3_github_scratch ? 1 : 0
  name   = "gha-${var.gh_org}-s3-scratch-${var.repo}-${var.role_name}"
  policy = data.aws_iam_policy_document.gha_s3_scratch_policy.json
  tags = {
    application = "github-actions"
    repo        = "${var.gh_org}/${var.repo}"
  }
}

resource "aws_iam_policy" "gha_role_policy" {
  name   = "gha-${var.gh_org}-${var.repo}-${var.role_name}"
  policy = var.policy_doc
  tags = {
    application = "github-actions"
    repo        = "${var.gh_org}/${var.repo}"
  }
}

resource "aws_iam_role_policy_attachment" "gh_scratch_attach" {
  count      = var.enable_s3_github_scratch ? 1 : 0
  policy_arn = aws_iam_policy.gha_s3_scratch_policy[0].arn
  role       = aws_iam_role.gha_oidc_assume_role.name
}


resource "aws_iam_role_policy_attachment" "pol_attach" {
  policy_arn = aws_iam_policy.gha_role_policy.arn
  role       = aws_iam_role.gha_oidc_assume_role.name
}

output "role_arn" {
  value = aws_iam_role.gha_oidc_assume_role.arn
}

output "policy_arn" {
  value = aws_iam_policy.gha_role_policy.arn
}

output "s3_scratch_location" {
  value = var.enable_s3_github_scratch ? "s3://${var.scratch_bucket}/${local.s3_scratch_prefix}" : "DISABLED"
}
