locals {
  s3_scratch_prefix = "${var.scratch_prefix}/${var.repo}/${var.role_name}"
  bucket_arn        = "arn:aws:s3:::${var.scratch_bucket}"
}
