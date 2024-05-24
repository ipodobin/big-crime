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

  acl    = "private"

  tags = {
    Name        = "BigCrimeDataBucket"
    Environment = "dev"
  }
}