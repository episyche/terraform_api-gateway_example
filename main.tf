provider "aws" {
  region = "ap-south-1"
}

resource "aws_api_gateway_rest_api" "EXAMPLE_API_GATEWAY" {
  name = "name of the API Gateway"
  description = "Description for API Gateway"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

resource "aws_api_gateway_resource" "USER_RESOURCE" {
    parent_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    path_part = "user"
}

resource "aws_api_gateway_method" "USER_GET_METHOD" {
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    resource_id = aws_api_gateway_resource.USER_RESOURCE.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "USER_GET_INTEGRATION" {
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    resource_id = aws_api_gateway_resource.USER_RESOURCE.id
    http_method = aws_api_gateway_method.USER_GET_METHOD.http_method
    integration_http_method = "GET"
    type = "HTTP"
    uri = " https://isro.vercel.app/api/centres"
    # request_templates = {
    #     "application/json" = ""
    # }
    # passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "USER_GET_METHOD_RESPONSE" {
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    resource_id = aws_api_gateway_resource.USER_RESOURCE.id
    http_method = aws_api_gateway_method.USER_GET_METHOD.http_method
    # http_method = "GET"
    status_code = "200"
    # response_models = {
    #     "application/json" = "Empty"
    # }
}

resource "aws_api_gateway_integration_response" "USER_GET_INTEGRATION_RESPONSE" {
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    resource_id = aws_api_gateway_resource.USER_RESOURCE.id
    http_method = aws_api_gateway_method.USER_GET_METHOD.http_method
    status_code = aws_api_gateway_method_response.USER_GET_METHOD_RESPONSE.status_code
    # response_templates = {
    #     "application/json" = ""
    # }
}


resource "aws_api_gateway_deployment" "USER_DEPLOYMENT" {
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    depends_on = [
        aws_api_gateway_resource.USER_RESOURCE,
        aws_api_gateway_method.USER_GET_METHOD,
        aws_api_gateway_integration.USER_GET_INTEGRATION,
        aws_api_gateway_method_response.USER_GET_METHOD_RESPONSE,
        aws_api_gateway_integration_response.USER_GET_INTEGRATION_RESPONSE
    ]
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "PROD_STAGE" {
    rest_api_id = aws_api_gateway_rest_api.EXAMPLE_API_GATEWAY.id
    deployment_id = aws_api_gateway_deployment.USER_DEPLOYMENT.id
    stage_name = "prod"
}