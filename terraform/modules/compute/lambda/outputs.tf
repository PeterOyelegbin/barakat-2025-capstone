output "lambda_name" {
    description = "Lambda function name"
    value       = aws_lambda_function.asset_processor.function_name
}
