locals {
  lifecycle_policy = {
    rules = [{
      rulePriority = 1
      description  = "Keep 50 images for production-*"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus     = "tagged"
        countType     = "imageCountMoreThan"
        countNumber   = 50
        tagPrefixList = ["production-"]
      }
      },
      {
        rulePriority = 2
        description  = "Keep 20 images for staging-*"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          countType     = "imageCountMoreThan"
          countNumber   = 20
          tagPrefixList = ["staging-"]
        }
      },
      {
        rulePriority = 3
        description  = "Keep 20 images for dev-*"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          countType     = "imageCountMoreThan"
          countNumber   = 20
          tagPrefixList = ["dev-"]
        }
      },

      {
        rulePriority = 4
        description  = "Keep 20 images for arm64-*"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          countType     = "imageCountMoreThan"
          countNumber   = 20
          tagPrefixList = ["arm64-"]
        }
      },
      {
        rulePriority = 5
        description  = "Keep 20 images for amd64-*"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          countType     = "imageCountMoreThan"
          countNumber   = 20
          tagPrefixList = ["amd64-"]
        }
    }]
  }

  cache_policy = {
    rules = [{
      rulePriority = 1
      description  = "Keep 50 images for caching"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 50
      }
      }]
}

}


module "ecrs" {
  source = "github.com/terraform-module/terraform-aws-ecr.git//.?ref=v1.0.6"

  ecrs = {
    anhlt-admin-webapp = {
      lifecycle_policy = local.lifecycle_policy
    },
    anhlt-backend = {
      lifecycle_policy = local.lifecycle_policy
    },
    anhlt-ecommerce-webapp = {
      lifecycle_policy = local.lifecycle_policy
    },
    anhlt-file = {
      lifecycle_policy = local.lifecycle_policy
    },
    anhlt-helper = {
      lifecycle_policy = local.lifecycle_policy
    },
    anhlt-iam = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-main-webapp = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-notification = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-oidc = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-partner-webapp = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-partner-webapp-v2 = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-payment = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-report = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-script = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-short-link = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-socket = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-landing-blog = {
      lifecycle_policy = local.lifecycle_policy
    }
    anhlt-landing-blog-cache = {
      lifecycle_policy = local.cache_policy
    }
  }
}
