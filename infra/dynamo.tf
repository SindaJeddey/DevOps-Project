resource "aws_dynamodb_table" "products-devops" {
  name         = "Products"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    "Name" = "${var.project}-products-${terraform.workspace}"
  }
}