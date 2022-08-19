provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket_website_configuration" "main_bucket_web_config" {
  bucket = aws_s3_bucket.main.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}
resource "aws_s3_bucket" "main" {
  bucket = "my-bucket"
  tags = {
    Name = "My Bucket"
    Environment = "Dev"
  }

}
resource "aws_s3_bucket_acl" "my_main_bucket_acl" {
  bucket = aws_s3_bucket.main.id
  acl    = "public-read"
}
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.main.id
  for_each = fileset("frontend-files/","*")
  key    = each.value
  source = "frontend-files/${each.value}"
  etag = filemd5("frontend-files/${each.value}")
}
output "bucket-arn" {
  value = aws_s3_bucket.main.arn
} 