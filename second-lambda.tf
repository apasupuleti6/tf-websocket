data "archive_file" "second_lambda" {
  type        = "zip"
  source_file = "function.mjs"
  output_path = "second_lambda_function_payload.zip"
}

resource "aws_lambda_function" "second_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "second_lambda_function_payload.zip"
  function_name    = "second_lambda_function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "function.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs18.x"
}

resource "aws_cloudwatch_log_group" "second-lambda" {
  name = "second-lambda"

  tags = {
    Environment = "dev"
  }
}

 //Code to subscribe and allow the invoke permission
resource "aws_sns_topic_subscription" "test_sns_lambda_target" {
  topic_arn = aws_sns_topic.test-topic.arn
  protocol  = "lambda"
  endpoint  =  aws_lambda_function.second_lambda.arn
}

resource "aws_lambda_permission" "with_test" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.second_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.test-topic.arn
}
