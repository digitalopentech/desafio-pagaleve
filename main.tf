provider "aws" {
  region  = "us-west-2" # Escolha sua região
  version = ">= 3.0"   # Especifique a versão que suporta "public_access_block_configuration"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
}

# S3 bucket
resource "aws_s3_bucket" "data_bucket" {
  bucket = "teste-projeto-aws-20231027185799"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "data_bucket_access_block" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

# DynamoDB Table
resource "aws_dynamodb_table" "orders_table" {
  name           = "OrdersTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# IAM Policy for Lambda to write to S3, read from DynamoDB Stream, and log to CloudWatch
resource "aws_iam_policy" "lambda_s3_dynamodb_policy" {
  name        = "lambda_s3_dynamodb_policy"
  description = "Allows Lambda to write to S3, read from DynamoDB Stream, and log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.data_bucket.arn}/*", 
          "${aws_dynamodb_table.orders_table.stream_arn}", 
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_dynamodb_policy.arn
}

# Attach policy to the Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_s3_dynamodb_attach" {
  policy_arn = aws_iam_policy.lambda_s3_dynamodb_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

# Lambda Function
#resource "aws_lambda_function" "process_orders" {
#  filename      = "lambda_function_payload.zip"  # Você precisa fornecer um arquivo zip com o código da Lambda
#  function_name = "process_orders"
#  role          = aws_iam_role.lambda_execution_role.arn
#  handler       = "index.handler"  # O ponto de entrada do seu código Lambda
#  source_code_hash = filebase64sha256("lambda_function_payload.zip")
#  runtime = "python3.8"
#}

# Lambda Function
resource "aws_lambda_function" "process_orders" {
  filename      = "lambda_function_payload.zip"
  function_name = "process_orders"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "process_data.lambda_handler"  # Atualizado para refletir o nome correto do arquivo e função

  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime = "python3.8"
}

resource "aws_s3_bucket_policy" "data_bucket_policy" {
  bucket = aws_s3_bucket.data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "${aws_iam_role.lambda_execution_role.arn}"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.data_bucket.arn}/*"
      }
    ]
  })
}

# DynamoDB Stream Trigger for Lambda
resource "aws_lambda_event_source_mapping" "dynamo_stream" {
  event_source_arn = aws_dynamodb_table.orders_table.stream_arn
  function_name    = aws_lambda_function.process_orders.arn
  starting_position = "TRIM_HORIZON"
}

# Redshift Cluster
resource "aws_redshift_cluster" "default" {
  cluster_identifier  = "redshift-cluster-1"
  database_name       = "mydb"
  master_username     = "admin"
  master_password     = "Red$hiftSecure!2023-PipeLines"
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  skip_final_snapshot = true
}
