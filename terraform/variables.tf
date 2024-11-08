variable "myregion" {
  default = "us-east-1"
  description = "Region where resources will be deployed"
}

variable "accountID" {
  description = "AWS account ID"
  sensitive = true
}