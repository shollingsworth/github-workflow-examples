resource "aws_ecr_repository" "repo" {
  name = local.ecr_repo_name
  # since this is a demo site, we can overwrite the image tag
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


output "repo_arn" {
  value = aws_ecr_repository.repo.arn
}
