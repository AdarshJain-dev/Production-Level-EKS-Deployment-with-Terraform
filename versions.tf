terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # use 6.x (latest stable major) — upgrade path from 5.x exists
    }
  }
}
