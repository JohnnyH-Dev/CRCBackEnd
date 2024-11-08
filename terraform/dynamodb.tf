resource "aws_dynamodb_table" "main" {
    name = "CRCVisitorCounter"
    hash_key = "counter_ID"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
      name = "counter_ID"
      type = "S"
    }
}