provider "aws" {
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_s3_bucket" "rivne_itstep" {
  bucket = "s3-rivne.itstep"
  acl    = "public-read"


  website {
    index_document = "index.html"
    error_document = "404.html"
  }


  versioning {
    enabled = true
  }
}

# resource "aws_s3_bucket_object" "html" {
#   for_each = fileset("../site/", "**/*.html")

#   bucket       = aws_s3_bucket.rivne_itstep
#   key          = each.value
#   source       = "../site/${each.value}"
#   etag         = filemd5("../site/${each.value}")
#   content_type = "text/html"
# }


