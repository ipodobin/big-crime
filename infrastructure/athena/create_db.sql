CREATE EXTERNAL TABLE `crimes`(
  `id` string,
  `case_number` string,
  `block` string,
  `primary_type` string,
  `location_description` string,
  `district` string,
  `date` string)
  PARTITIONED BY (`community_area` string)
  ROW FORMAT SERDE
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
  STORED AS INPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
  OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
  LOCATION
  's3://780087431924-formatted-data/'
  TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0',
  'CrawlerSchemaSerializerVersion'='1.0',
  'UPDATED_BY_CRAWLER'='review_crawler',
  'averageRecordSize'='1459',
  'classification'='parquet',
  'compressionType'='none',
  'objectCount'='1',
  'recordCount'='100000',
  'sizeKey'='94807077',
  'typeOfData'='file')