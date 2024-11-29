# Feature added for Markus Henzka
# Currently only works in our devops dev environment because of the requirement for a specific role

data "aws_iam_role" "lambda_exec_ce" {
  name = "TVM_RoleRetriever_lambda"
}

# Second instance of role retriever for CE_ roles for Markus
resource "aws_lambda_function" "lambda_python_roleretriever_ce" {
  function_name = "App_RoleRetriever_CE"

  s3_bucket = var.python-storage-bucket-name
  s3_key    = aws_s3_bucket_object.lambda_python_roleretriever.key

  runtime = "python3.9"
  handler = "getrole.lambda_handler"

  timeout = 30

  source_code_hash = data.archive_file.lambda_python_roleretriever.output_base64sha256

  role = data.aws_iam_role.lambda_exec_ce.arn
  
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

