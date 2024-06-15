#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
export AWS_ACCOUNT_ID
echo $AWS_ACCOUNT_ID
export BIG_CRIME_GLUE_DB_NAME="big-crime-db"

export LANDING_ZONE_BUCKET_NAME="landing-zone"
aws s3api create-bucket --bucket $AWS_ACCOUNT_ID-$LANDING_ZONE_BUCKET_NAME --region us-east-1
envsubst <./landing_zone_bucket_policy.json >resource.json
aws s3api put-public-access-block \
    --bucket $AWS_ACCOUNT_ID-$LANDING_ZONE_BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-bucket-policy --bucket $AWS_ACCOUNT_ID-$LANDING_ZONE_BUCKET_NAME --policy file://./resource.json

export FORMATTED_DATA_BUCKET_NAME="formatted-data"
aws s3api create-bucket --bucket $AWS_ACCOUNT_ID-$FORMATTED_DATA_BUCKET_NAME --region us-east-1
envsubst <./formatted_data_bucket_policy.json >resource.json
aws s3api put-public-access-block \
    --bucket $AWS_ACCOUNT_ID-$FORMATTED_DATA_BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-bucket-policy --bucket $AWS_ACCOUNT_ID-$FORMATTED_DATA_BUCKET_NAME --policy file://./resource.json

aws s3api create-bucket --bucket $AWS_ACCOUNT_ID-app --region us-east-1
envsubst <./01_to_parquet_conversion.py >script.py
aws s3 cp script.py s3://$AWS_ACCOUNT_ID-app/glue/scripts/
aws glue create-job \
    --name big-crime-preprocessing \
    --job-mode "SCRIPT" \
    --role "arn:aws:iam::$AWS_ACCOUNT_ID:role/LabRole" \
    --command "{
        \"Name\": \"glueetl\",
        \"ScriptLocation\": \"s3://$AWS_ACCOUNT_ID-app/glue/scripts/script.py\",
        \"PythonVersion\": \"3\"
    }" \
    --region us-east-1 \
    --output json \
    --default-arguments "{
       \"--enable-metrics\": \"true\",
       \"--enable-spark-ui\": \"true\",
       \"--spark-event-logs-path\": \"s3://$AWS_ACCOUNT_ID-app/glue/sparkHistoryLogs/\",
       \"--enable-job-insights\": \"false\",
       \"--enable-observability-metrics\": \"true\",
       \"--enable-glue-datacatalog\": \"true\",
       \"--enable-continuous-cloudwatch-log\": \"true\",
       \"--job-bookmark-option\": \"job-bookmark-disable\",
       \"--job-language\": \"python\",
       \"--TempDir\": \"s3://$AWS_ACCOUNT_ID-app/glue/temporary/\"
   }"

# create glue database
aws glue create-database --database-input "{\"Name\":\"$BIG_CRIME_GLUE_DB_NAME\"}"
