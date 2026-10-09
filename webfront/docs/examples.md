## Example - Secure S3 Bucket with CloudFront and Custom Domain

```hcl
module "webfront" {
  source = "../webfront"

  environment = "prod"
  revision    = "1.0.0"

  # S3 Configuration
  bucket_name           = "myapp-prod-static-assets"
  enable_host_error_pages = true

  html_pages = [
    {
      key         = "index.html"
      source_file = "./dist/index.html"
    },
    {
      key         = "error.html"
      source_file = "./dist/error.html"
    }
  ]

  # CloudFront Configuration
  enable_cloudfront     = true
  comment               = "MyApp Production - Static Assets"
  price_class           = "PriceClass_200"
  min_tls_version       = "TLSv1.2_2021"

  custom_domain_names   = ["static.example.com"]
  ssl_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"

  tags = {
    Team       = "frontend"
    CostCenter = "12345"
  }
}
```
