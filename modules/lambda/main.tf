terraform {
  required_version = ">=0.15.5"
}

# lambdas 
resource "aws_lambda_function" "fn" {
  function_name = var.function_name
  runtime       = "nodejs10.x"

  s3_bucket = var.s3_bucket
  s3_key    = "v${var.app_version}/main.zip"
  handler   = "main.handler"

  role    = var.aws_iam_role
  publish = true
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = var.gateway.id
  resource_id = var.method.resource_id
  http_method = var.method.http_method

  # lambda functions can only be invocked by POST
  integration_http_method = "POST"
  # AWS_PROXY for lambda proxy integration
  type = "AWS_PROXY"
  uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.fn.arn}:$${stageVariables.version}/invocations"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]

  rest_api_id = var.gateway.id
  #   triggers = {
  #     redeployment = sha1(file("main.tf"))
  #   }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_alias" "alias" {
  name             = var.alias
  function_name    = aws_lambda_function.fn.arn
  function_version = aws_lambda_function.fn.version
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = var.gateway.id
  stage_name    = var.alias
  variables = {
    "version" : var.alias
  }
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.fn.function_name}:${var.alias}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.gateway.id}/*/*/*"
}
