#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
export AWS_ACCOUNT_ID
export BIG_CRIME_KINESIS_ANALYTICAL_APPLICATION_NAME="big-crime-stream-notebook"
export BIG_CRIME_KINESIS_CRIMES_STREAM_NAME="big-crime-stream-crimes"
export BIG_CRIME_KINESIS_SUMMARY_STREAM_NAME="big-crime-stream-summary"
export BIG_CRIME_GLUE_DB_NAME="big-crime-stream-db"

aws s3api create-bucket --bucket $AWS_ACCOUNT_ID-flink --region us-east-1

# create kinesis streams
aws kinesis create-stream \
    --stream-name $BIG_CRIME_KINESIS_CRIMES_STREAM_NAME \
    --shard-count 2
aws kinesis create-stream \
    --stream-name $BIG_CRIME_KINESIS_SUMMARY_STREAM_NAME \
    --shard-count 1

# create glue database
aws glue create-database --database-input "{\"Name\":\"$BIG_CRIME_GLUE_DB_NAME\"}"

# create and start kinesis analysis studio notebook
envsubst <./flink_studio_notebooks/create_studio_notebook.json >resource.json
aws kinesisanalyticsv2 create-application --cli-input-json file://./resource.json
aws kinesisanalyticsv2 start-application --application-name $BIG_CRIME_KINESIS_ANALYTICAL_APPLICATION_NAME
rm resource.json
envsubst <./zeppelin_notebook_template.ipynb >zeppelin_notebook.ipynb

# create lambda function for streaming data provider
envsubst <./lambda_function_template.py >lambda_function.py
zip -r lambda_function.zip lambda_function.py
aws lambda create-function \
    --function-name big-crime-streaming-producer \
    --region us-east-1 \
    --runtime python3.12 \
    --role "arn:aws:iam::${AWS_ACCOUNT_ID}:role/LabRole" \
    --zip-file fileb://lambda_function.zip \
    --handler lambda_function.lambda_handler \
    --memory-size 512 \
    --timeout 300

