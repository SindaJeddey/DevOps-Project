resource "aws_s3_bucket" "devops-hosting" {
  bucket = var.project
  acl    = "public-read"
  policy = data.aws_iam_policy_document.s3-policy.json
  website {
    index_document = "index.html"
  }
  tags = {
    Name = "${var.project}-s3"
  }
}

data "aws_iam_policy_document" "s3-policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${var.project}/*"
    ]
  }
}