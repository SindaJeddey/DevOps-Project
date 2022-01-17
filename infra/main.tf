terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.72.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_dynamodb_table" "products-devops" {
  name     = "Products"
  hash_key = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    "Name" = "products-${terraform.workspace}"
  }
}