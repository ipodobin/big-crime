resource "aws_s3_bucket" "big_crime_landing_zone_bucket" {
  bucket = "big-crime-landing-zone"

  tags = {
    Name        = "BigCrimeDataBucket"
    Environment = "dev"
  }

  force_destroy = true
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

  force_destroy = true
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
