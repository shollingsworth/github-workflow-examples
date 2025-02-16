resource "aws_codeartifact_domain" "domain" {
  domain = "shollingsworth"
}

resource "aws_codeartifact_repository" "pypi-upstream" {
  repository  = "pypi-store"
  description = "Provides PyPI artifacts from PyPI"
  domain      = aws_codeartifact_domain.domain.domain

  external_connections {
    external_connection_name = "public:pypi"
  }
}

resource "aws_codeartifact_repository" "python_package" {
  repository  = "${local.gh_repo}-python"
  description = "Example ${local.gh_repo} python package"
  domain      = aws_codeartifact_domain.domain.domain
}

resource "aws_codeartifact_repository" "private" {
  repository  = "shollingsworth-private"
  domain      = aws_codeartifact_domain.domain.domain
  description = "hosted python artifacts"

  dynamic "upstream" {
    for_each = toset([
      aws_codeartifact_repository.pypi-upstream.repository,
      aws_codeartifact_repository.python_package.repository,
    ])
    content {
      repository_name = upstream.value
    }
  }
}
