provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# CLOUDFRONT HAS REMOVE CLOUDFLARE CA FROM TRUSTED CA LIST 2019
provider "aws" {
  region = "us-east-1"
  alias  = "global"
  profile = "anhlt-devops"
}

