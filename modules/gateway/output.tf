output "gateway" {
  value = aws_api_gateway_rest_api.api
}
output "method" {
  value = aws_api_gateway_method.any
}

output "iamRole" {
  value = aws_iam_role.lambdaExec.arn
}
