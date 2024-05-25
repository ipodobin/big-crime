terraform {
  backend "s3" {
    bucket = "big-crime-tfstate"
    key    = "big-crime/tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "big_crime_data_bucket" {
  bucket = "big-crime-data"

  tags = {
    Name        = "BigCrimeDataBucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "big_crime_public_access" {
  bucket = aws_s3_bucket.big_crime_data_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.big_crime_data_bucket.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadWrite",
        "Effect": "Allow",
        "Principal": "*",
        "Action": ["s3:GetObject","s3:PutObject"],
        "Resource": [
          "arn:aws:s3:::big-crime-data/*"
        ]
      }
    ]
  }
EOF
}