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

}
resource "aws_s3_bucket" "main" {
  bucket = "cloudess-bucket"
  tags = {
    Name = "My Bucket"
    Environment = "Development"
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
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.access_bucket_object.json
}
data "aws_iam_policy_document" "access_bucket_object" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.main.bucket}/*"]
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}

output "bucket-website_domain" {
  value = aws_s3_bucket.main.website_domain
} 