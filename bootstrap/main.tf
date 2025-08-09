provider "aws" {
  region = "us-east-1"
}

# Creating S3 bucket
resource "aws_s3_bucket" "data_bucket" {
    bucket = "hbd-terra-bucket"
    tags = {
        Name = "data_bucket"
        Env = "Dev"
        Terraform = true
        }
    }

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_dynamodb_table" "lock" {
  name         = "terraform-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute  {
      name = "LockID"
      type = "S"
  }
}
