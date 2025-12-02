terraform {
  backend "s3" {
    bucket         = "terraform-state-file-s3-223"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
