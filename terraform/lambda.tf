data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "${path.module}/lambda_function/"
  output_path = "${path.module}/lambda_function/lambda_function.zip"
}

resource "aws_lambda_function" "name" {
    filename = data.archive_file.lambda.output_path
    function_name = "VisitorCounterFunction"
    role = aws_iam_role.iam_for_lambda.arn
    handler = "lambda_function.lambda_handler"
    runtime = "python3.9"

}