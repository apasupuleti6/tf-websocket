data "archive_file" "authorizer_lambda" {
  type        = "zip"
  source_file = "authorizer.mjs"
  output_path = "${local.zip_path}/authorizer_lambda.zip"
}

resource "aws_lambda_function" "authorizer_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${local.zip_path}/authorizer_lambda.zip"
  function_name    = "authorizer_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "authorizer.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs18.x"
}

resource "aws_cloudwatch_log_group" "authorizer-lambda" {
  name = "authorizer_lambda_log_group"
  retention_in_days = "${local.log_rentention}"
  tags = {
    Environment = "dev"
  }
}


resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id           = aws_apigatewayv2_api.websocket-gw.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.authorizer_lambda.invoke_arn
  identity_sources = ["route.request.querystring.authorizationToken"]
  name             = "api-authorizer"
}

