resource "aws_apigatewayv2_api" "websocket-gw" {
  name                       = "websocket-tf-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.websocket-gw.id
  name        = "websocket-tf-dev-stage"
  auto_deploy = false

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      validationErrorString   = "$context.error.validationErrorString"
      errorResponseType       = "$context.error.responseType"
      }
    )
  }
}




resource "aws_apigatewayv2_route" "apigateway_route_default" {
  api_id    = aws_apigatewayv2_api.websocket-gw.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.connect_lamda.id}"
}


/* route and integration for $connect */
resource "aws_apigatewayv2_route" "apigateway-route-c" {
  api_id    = aws_apigatewayv2_api.websocket-gw.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect_lamda.id}"
}

resource "aws_apigatewayv2_integration" "connect_lamda" {
  api_id           = aws_apigatewayv2_api.websocket-gw.id
  integration_uri  = aws_lambda_function.websocket_lambda_connect.invoke_arn
  integration_type = "AWS_PROXY"

}
/* route and integration for $disconnect */
resource "aws_apigatewayv2_route" "apigateway-route-d" {
  api_id    = aws_apigatewayv2_api.websocket-gw.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.disconnect_lamda.id}"
}

resource "aws_apigatewayv2_integration" "disconnect_lamda" {
  api_id           = aws_apigatewayv2_api.websocket-gw.id
  integration_uri  = aws_lambda_function.websocket_lambda_disconnect.invoke_arn
  integration_type = "AWS_PROXY"

}
resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.websocket-gw.name}"

  retention_in_days = 1
}


