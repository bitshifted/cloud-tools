# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


output "table_arn" {
  value       = aws_dynamodb_table.db_table.arn
  description = "ARN of created Dynamo DB table"
}

output "table_name" {
  value       = aws_dynamodb_table.db_table.name
  description = "Name of created Dynamo DB table"
}