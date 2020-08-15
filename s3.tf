resource "aws_s3_bucket" "s3_storage" {
  bucket = "s3-storage-tesssss"  ## should be unique bucket name
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

}