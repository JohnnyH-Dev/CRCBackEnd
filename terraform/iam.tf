data "aws_iam_policy_document" "assume_role" {
    statement {
      effect = "Allow"

      principals {
            type = "Service"
            identifiers = [ "lambda.amazonaws.com" ]
      }

      actions = ["sts: AssumeRole"]
    }
  
}

data "aws_iam_policy_document" "dynamodb_lambda" {
    statement {
      effect = "Allow"
      actions = [
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ]
      resources = [ aws_dynamodb_table.main.arn ]
    }
  
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "dynamodb_permissions" {
    name = "dynamodb_permissions"
    role = aws_iam_role.iam_for_lambda.name
    policy = data.aws_iam_policy_document.dynamodb_lambda.json
}