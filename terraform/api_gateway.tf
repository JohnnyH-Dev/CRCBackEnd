resource "aws_api_gateway_rest_api" "main" {
    name = "lambda_api_gateway"
    description = "API Gateway for Lambda visitor counter function"
}

resource "aws_api_gateway_resource" "main" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    parent_id = aws_api_gateway_rest_api.main.root_resource_id
    path_part = "visitor_counter"
}

resource "aws_api_gateway_method" "main" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "main" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = aws_api_gateway_method.main.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.name.invoke_arn
}

resource "aws_lambda_permission" "main" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.name.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountID}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.main.http_method}/visitor_counter"
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.main.id,
      aws_api_gateway_method.main.id,
      aws_api_gateway_integration.main.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"
}

# Added to address CORS issues between browser and API

# Define the OPTIONS method for CORS preflight
resource "aws_api_gateway_method" "options" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = "OPTIONS"
    authorization = "NONE"
}

# Use a mock integration for the OPTIONS method
resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = aws_api_gateway_method.options.http_method
    type = "MOCK"

    request_templates = {
        "application/json" = "{\"statusCode\": 200}"
    }
}

# Define the method response for OPTIONS, including CORS headers
resource "aws_api_gateway_method_response" "options_response" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = aws_api_gateway_method.options.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
    }
}

# Define the integration response for the OPTIONS method to include CORS headers
resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = aws_api_gateway_method.options.http_method
    status_code = aws_api_gateway_method_response.options_response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
        "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    }
}

# Define the method response for POST, including CORS headers
resource "aws_api_gateway_method_response" "post_response" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = aws_api_gateway_method.main.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
    }
}

# Define the integration response for the POST method to include CORS headers
resource "aws_api_gateway_integration_response" "post_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.main.id
    resource_id = aws_api_gateway_resource.main.id
    http_method = aws_api_gateway_method.main.http_method
    status_code = aws_api_gateway_method_response.post_response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
        "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    }
}