module "function" {
  source = "./modules/lambda"
  depends_on = [
    module.apiGateway
  ]
  function_name = "example"
  s3_bucket     = "terraform-lambda-example/"
  app_version   = "1.0.0"
  alias         = "v1"
  gateway       = module.apiGateway.gateway
  method        = module.apiGateway.method
  region        = local.region
  account_id    = local.accountId
  aws_iam_role  = module.apiGateway.iamRole

}


