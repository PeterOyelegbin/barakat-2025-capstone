# ZIP the lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_func.py"
  output_path = "${path.module}/lambda_func.zip"
}

# Lambda function
resource "aws_lambda_function" "asset_processor" {
  function_name    = var.lambda_func_name
  role             = var.lambda_role_arn
  handler          = "lambda_func.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Allow S3 to invoke lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

# S3 event notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
