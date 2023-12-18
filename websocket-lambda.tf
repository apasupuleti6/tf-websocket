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


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.mjs"
  output_path = "websocket_lambda_function_payload.zip"
}

resource "aws_lambda_function" "websocket_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "websocket_lambda_function_payload.zip"
  function_name    = "websocket_lambda_function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs18.x"
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