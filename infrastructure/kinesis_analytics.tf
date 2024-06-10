
resource "aws_kinesis_stream" "big_crime_stream" {
  name             = "big-crime-stream"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_glue_catalog_database" "big_crime_catalog" {
  name = "big-crime-glue-db-for-stream"
}

# resource "aws_kinesisanalyticsv2_application" "big_crime_flink" {
#   name                   = "big-crime-flink-application"
# #   runtime_environment    = "FLINK-1_18"
# #   application_mode       = "STREAMING"
#   runtime_environment    = "ZEPPELIN-FLINK-3_0"
#   service_execution_role = "arn:aws:iam::780087431924:role/LabRole"
#   application_mode       = "INTERACTIVE"
#   application_configuration {
#     zeppelin_application_configuration {
#       catalog_configuration {
#         glue_data_catalog_configuration {
#           database_arn   = aws_glue_catalog_database.big_crime_catalog.arn
#         }
#       }
#     }
#   }
# }