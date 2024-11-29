data "archive_file" "lambda_python_roleretriever" {
  type = "zip"

  source_dir  = "${path.module}/python"
  output_path = "${path.module}/lambda_python_roleretriever.zip"
}

data "aws_subnet" "subnet1" {
  vpc_id    = data.aws_vpc.vpc.id

  tags = {
    Terraform_Resource = "CE_Subnet" #"CE_Subnet"
    Terraform_Role = "service" # "service"
    Terraform_ID = 1
  }
}

data "aws_vpc" "vpc" {
  tags = {
    Terraform_Resource = "CE_VPC" # "CE_VPC"
  }
}

data "aws_security_group" "internet"  {
  vpc_id    = data.aws_vpc.vpc.id
  tags = {
    Terraform_Resource = "CE_SG"
    Terraform_Role = "Internet_Access"
  }  
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_s3_bucket_object" "lambda_python_roleretriever" {
  bucket = var.python-storage-bucket-name

  key    = "lambda_python_roleretriever.zip"
  source = data.archive_file.lambda_python_roleretriever.output_path

  etag = filemd5(data.archive_file.lambda_python_roleretriever.output_path)
}

resource "aws_lambda_function" "lambda_python_roleretriever" {
  function_name = "App_RoleRetriever"

  s3_bucket = var.python-storage-bucket-name
  s3_key    = aws_s3_bucket_object.lambda_python_roleretriever.key

  runtime = "python3.9"
  handler = "getrole.lambda_handler"

  timeout = 30

  source_code_hash = data.archive_file.lambda_python_roleretriever.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
  
  vpc_config {
    subnet_ids         = [ data.aws_subnet.subnet1.id ]    # ["subnet-049c55c7e0313de45"] #hard coded because data tags didnt work for some reason
    security_group_ids = [ data.aws_security_group.internet.id, data.aws_security_group.default.id ]   # ["sg-0120a030bad5619a1", "sg-0df5c8cac4fa5e967"] #default security group + internet group in the devops dev account
  }

  environment {
      variables = {
        feature_inputlogging = var.feature_inputlogging
        feature_outputlogging = var.feature_outputlogging
        feature_enabled = var.feature_enabled
      }
  }
}

#resource "aws_lambda_alias" "lambda_alias" {
#  name             = "role_retriever_alias"
#  description      = "development version"
#  function_name    = aws_lambda_function.lambda_python_roleretriever.arn
#  function_version = 1
#}

resource "aws_cloudwatch_log_group" "lambda_python_roleretriever" {
  name = "/aws/lambda/${aws_lambda_function.lambda_python_roleretriever.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "App_roleretriever_lambda"
  permissions_boundary = var.permissions_boundary_arn
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Action": "sts:AssumeRole",
"Principal": {
"Service": "lambda.amazonaws.com"
},
"Effect": "Allow",
"Sid": ""
}
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "App_lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "app_lambda_policy" {
    role = aws_iam_role.lambda_exec.id
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [ 
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:CreateSecret",
        "secretsmanager:UpdateSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:TagResource",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  depends_on = [aws_iam_role.lambda_exec]
}

resource "aws_secretsmanager_secret" "adminkey_secret" {
  name = "eccs/devops/roleretriever/adminkey_v02"
  recovery_window_in_days=0
}

resource "aws_secretsmanager_secret_version" "adminkey_secret_version" {
  secret_id     = aws_secretsmanager_secret.adminkey_secret.id
  secret_string = jsonencode(local.adminkey)
}

locals {
  adminkey = {
    adminkey = var.ADMINKEY
  }
}


resource "aws_secretsmanager_secret" "smtp_password_secret" {
  name = "eccs/devops/roleretriever/smtp_password"
  recovery_window_in_days=0
}

resource "aws_secretsmanager_secret_version" "smtp_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.smtp_password_secret.id
  secret_string = local.smtp_password
}

locals {
  smtp_password = var.SMTP_PASSWORD
}