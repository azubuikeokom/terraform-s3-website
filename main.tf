provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket_website_configuration" "main_bucket_web_config" {
  bucket = aws_s3_bucket.main.bucket

  index_document {
    suffix = "index.html"
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
  content_type = each.value == "index.html" ? "text/html" : "text/css"
  
}
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.access_bucket_object.json
}
data "aws_iam_policy_document" "access_bucket_object" {
  statement {
    sid = "public_access_bucket"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.main.bucket}/*"]
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}

output "bucket-website_domain" {
  value = aws_s3_bucket.main.bucket_regional_domain_name
}

#cloudfront configuration

locals {
  s3_origin_id = "cloudesse"
}
resource "aws_cloudfront_origin_access_identity" "my_cloudfront_id" {
  comment = "Origin Access Identity for Serverless Static Website"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.my_cloudfront_id
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront configuration"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  #aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  # restrictions {
  #   geo_restriction {
  #     restriction_type = "whitelist"
  #     locations        = ["US", "CA", "GB", "DE"]
  #   }
  # }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}