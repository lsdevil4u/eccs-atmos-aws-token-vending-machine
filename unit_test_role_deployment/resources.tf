

locals {
  entityid = {
    entityid = var.IAM_ENTITYID
  }
}

locals {
  wildcardentityid = {
    wildcardentityid = var.IAM_WILDCARDENTITYID
  }
}

resource "aws_iam_role" "tvm_assume" {
  name = "App_token_vending_machine_target"
  permissions_boundary = var.permissions_boundary_arn
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "AWS": "arn:aws:iam::095208641432:role/App_roleretriever_lambda"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "StringEquals": {"sts:ExternalId": "${var.IAM_ENTITYID}" }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "tvm_wildcard_assume" {
  name = "App_token_vending_machine_wildcard_target"
  permissions_boundary = var.permissions_boundary_arn
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "AWS": "arn:aws:iam::095208641432:role/App_roleretriever_lambda"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "StringEquals": {"sts:ExternalId": "${var.IAM_WILDCARDENTITYID}" }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "tvm_assume_gl" {
  name = "App_token_vending_machine_gitlab_target"
  permissions_boundary = var.permissions_boundary_arn
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "AWS": "arn:aws:iam::139852950170:role/App_roleretriever_lambda"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "StringEquals": {"sts:ExternalId": "${var.IAM_ENTITYID}" }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "tvm_wildcard_assume_gl" {
  name = "App_token_vending_machine_gitlab_wildcard_target"
  permissions_boundary = var.permissions_boundary_arn
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "AWS": "arn:aws:iam::139852950170:role/App_roleretriever_lambda"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "StringEquals": {"sts:ExternalId": "${var.IAM_WILDCARDENTITYID}" }
      }
    }
  ]
}
EOF
}