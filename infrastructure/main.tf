provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "big_crime_bucket" {
  bucket = "big-crime-imw"

  acl    = "private"

  tags = {
    Name        = "BigCrimeBucket"
    Environment = "Production"
  }
}