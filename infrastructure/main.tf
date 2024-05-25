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

resource "aws_s3_bucket" "big_crime_landing_zone_bucket" {
  bucket = "big-crime-landing-zone"

  tags = {
    Name        = "BigCrimeDataBucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "big_crime_landing_zone_bucket_public_access" {
  bucket = aws_s3_bucket.big_crime_landing_zone_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "big_crime_landing_zone_bucket_bucket_policy" {
  bucket = aws_s3_bucket.big_crime_landing_zone_bucket.id

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
          "arn:aws:s3:::big-crime-landing-zone/*"
        ]
      }
    ]
  }
EOF
}

resource "aws_s3_bucket" "big_crime_formatted_data_bucket" {
  bucket = "big-crime-formatted-data"

  tags = {
    Name        = "BigCrimeDataBucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "big_crime_formatted_data_bucket_public_access" {
  bucket = aws_s3_bucket.big_crime_formatted_data_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "big_crime_formatted_data_bucket_bucket_policy" {
  bucket = aws_s3_bucket.big_crime_formatted_data_bucket.id

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
          "arn:aws:s3:::big-crime-formatted-data/*"
        ]
      }
    ]
  }
EOF
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "mysubnet"
  }
}

resource "aws_instance" "nifi" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id
  tags = {
    Name = "nifi"
  }
}