data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com", "lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_basic_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_gw" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}


resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
  name = "dynamodb_lambda_policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["dynamodb:*"],
        "Resource" : "${aws_dynamodb_table.connection-dynamodb-table.arn}"
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.mjs"
  output_path = "${local.zip_path}/websocket_lambda_connect.zip"
}
/* $connect lambda function and permission*/

resource "aws_lambda_function" "websocket_lambda_connect" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${local.zip_path}/websocket_lambda_connect.zip"
  function_name    = "websocket_connect_lambda_function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs18.x"
}



resource "aws_lambda_permission" "websocket_lambda_connect_link_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_lambda_connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket-gw.execution_arn}/*/*"
}


data "archive_file" "lambda_disconnect" {
  type        = "zip"
  source_file = "disconnect.mjs"
  output_path = "${local.zip_path}/websocket_lambda_disconnect.zip"
}



/* $disconnect lambda function and persmission */

resource "aws_lambda_function" "websocket_lambda_disconnect" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${local.zip_path}/websocket_lambda_disconnect.zip"
  function_name    = "websocket_lambda_disconnect_function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "disconnect.handler"
  source_code_hash = data.archive_file.lambda_disconnect.output_base64sha256
  runtime          = "nodejs18.x"
}



resource "aws_lambda_permission" "websocket_lambda_disconnect_link_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_lambda_disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket-gw.execution_arn}/*/*"
}
resource "aws_cloudwatch_log_group" "websocket-lambda" {
  name = "websocket-lambda"

  tags = {
    Environment = "dev"
  }
}



# data "aws_iam_policy_document" "lambda_logging" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = ["arn:aws:logs:*:*:*"]
#   }
# }

# resource "aws_iam_policy" "lambda_logging" {
#   name        = "lambda_logging"
#   path        = "/"
#   description = "IAM policy for logging from a lambda"
#   policy      = data.aws_iam_policy_document.lambda_logging.json
# }

# resource "aws_iam_role_policy_attachment" "lambda_logs" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = aws_iam_policy.lambda_logging.arn
# }