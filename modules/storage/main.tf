# ── 1. THE S3 BUCKET 
resource "random_id" "bucket_suffix" {
  byte_length = 4   # produces an 8-character hex string
}

resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-bucket"
  })
}

# ── 2. BLOCK ALL PUBLIC ACCESS 
# By default, S3 buckets are private. This resource makes it explicit
# and prevents any accidental public exposure — a common security mistake.
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── 3. VERSIONING (optional, controlled by a variable) 
resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# ── 4. LIFECYCLE POLICY
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"   # only applies to objects whose key starts with "logs/"
    }

    expiration {
      days = 90
    }
  }
}
