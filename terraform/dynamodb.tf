resource "aws_dynamodb_table" "main" {
    name = "CRCVisitorCounter"
    hash_key = "counter_ID"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
      name = "counter_ID"
      type = "S"
    }
}

resource "aws_dynamodb_table_item" "initial_visitor_count" {
  table_name = aws_dynamodb_table.main.name
  hash_key = "counter_ID"

  item = <<ITEM
  {
    "counter_ID": {"S": "visitor_counter"},
    "visitor_count": {"N": "0"}
  }
  ITEM

  lifecycle {
    ignore_changes = [ item ]
  }
}
