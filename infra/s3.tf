resource "aws_s3_bucket" "devops-hosting" {
  bucket = "insat-${var.project}"
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
      "arn:aws:s3:::insat-${var.project}/*"
    ]
  }
}

resource "null_resource" "s3-bucket" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "truncate -s 0 ../client/.make_env && echo 'region=${aws_s3_bucket.devops-hosting.region}\nbucket_name=${aws_s3_bucket.devops-hosting.id}'>../client/.make_env"
  }
}