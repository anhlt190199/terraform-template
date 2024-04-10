# --- s3 bucket for runner s3 cache
resource "aws_s3_bucket" "runner_s3_cache" {
  bucket = "${var.common_name_prefix}-runner-s3-cache"

  tags = {
    Name = "${var.common_name_prefix}-runner-s3-cache"
  }
}

resource "aws_s3_bucket_acl" "runner-s3-cache" {
  bucket = aws_s3_bucket.runner_s3_cache.id
  acl    = "private"
}