resource "aws_s3_bucket" "github-scratch" {
  bucket = local.gh_scratch_bucket
}

resource "aws_s3_bucket_public_access_block" "github-scratch" {
  bucket                  = aws_s3_bucket.github-scratch.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "github-scratch" {
  bucket = aws_s3_bucket.github-scratch.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "github-scratch" {
  bucket = aws_s3_bucket.github-scratch.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}


data "aws_iam_policy_document" "github-scratch-bucket-policy" {
  # whole bucket policy

  # ensure objects are encrypted
  statement {
    effect = "Deny"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.github-scratch.arn}/*",
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values = [
        "true"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "github-scratch-bucket-policy" {
  bucket = aws_s3_bucket.github-scratch.id
  policy = data.aws_iam_policy_document.github-scratch-bucket-policy.json
}
