import json
import boto3
import time
import random
from datetime import datetime, date, timedelta
import logging

logger = logging.getLogger()
logger.setLevel("INFO")

stream_name = '${BIG_CRIME_KINESIS_CRIMES_STREAM_NAME}'
bucket_name =  '${AWS_ACCOUNT_ID}-landing-zone'
key = '2024-06-11/'
region_name = 'us-east-1'

kinesis_client = boto3.client('kinesis', region_name=region_name)
s3_resource = boto3.resource('s3')
s3_client = boto3.client("s3")

def lambda_handler(event, context):
    logger.info("Lambda invoked")
    all_objects = s3_client.list_objects(Bucket = bucket_name, Prefix = key)

    for info in all_objects['Contents']:
        obj = s3_resource.Object(bucket_name, info['Key'])
        data = obj.get()['Body'].read().decode('utf-8')
        data = data.replace("\n", ",")
        data = '[' + data + ']'
        json_data = json.loads(data)

        count = 0
        ts_1 = time.time()
        size = len(json_data)
        step = 10
        for x in range(0, size - 1, step):
            part = json_data[x : x + step - 1]
            records = []
            for record in part:
                record['event_time'] = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
                record['event_time_for_sql'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                if 'community_area' in record : record['community_area'] = community_areas.get(record['community_area'], None)
                records.append({
                    'Data': json.dumps(record),
                    'PartitionKey': record['community_area']
                })
            kinesis_client.put_records(
                StreamName=stream_name, Records=records
            )
            count += len(records)
            ts_2 = time.time()
            diff = ts_2 - ts_1
            if diff > 5.0:
                print(f'rate = {count / diff}/sec')
                ts_1 = time.time()
                count = 0
            # time.sleep(random.randint(10, 100)/1000.0)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!!!')
    }

community_areas = {
    "1":  "Rogers Park",
    "2":  "West Ridge",
    "3":  "Uptown",
    "4":  "Lincoln Square",
    "5":  "North Center",
    "6":  "Lake View",
    "7":  "Lincoln Park",
    "8":  "Near North Side",
    "9":  "Edison Park ",
    "10":     "Norwood Park",
    "11":     "Jefferson Park",
    "12":     "Forest Glen",
    "13":     "North Park",
    "14":     "Albany Park",
    "15":     "Portage Park",
    "16":     "Irving Park",
    "17":     "Dunning",
    "18":     "Montclare",
    "19":     "Belmont Cragin",
    "20":     "Hermosa",
    "21":     "Avondale",
    "22":     "Logan Square",
    "23":     "Humboldt Park",
    "24":     "West Town",
    "25":     "Austin",
    "26":     "West Garfield Park",
    "27":     "East Garfield Park",
    "28":     "Near West Side",
    "29":     "North Lawndale",
    "30":     "South Lawndale",
    "31":     "Lower West Side",
    "32":     "Loop",
    "33":     "Near South Side",
    "34":     "Armour Square",
    "35":     "Douglas",
    "36":     "Oakland",
    "37":     "Fuller Park",
    "38":     "Grand Boulevard",
    "39":     "Kenwood",
    "40":     "Washington Park",
    "41":     "Hyde Park",
    "42":     "Woodlawn",
    "43":     "South Shore",
    "44":     "Chatham",
    "45":     "Avalon Park",
    "46":     "South Chicago",
    "47":     "Burnside",
    "48":     "Calumet Heights",
    "49":     "Roseland",
    "50":     "Pullman",
    "51":     "South Deering",
    "52":     "East Side",
    "53":     "West Pullman",
    "54":     "Riverdale",
    "55":     "Hegewisch",
    "56":     "Garfield Ridge",
    "57":     "Archer Heights",
    "58":     "Brighton Park",
    "59":     "McKinley Park",
    "60":     "Bridgeport",
    "61":     "New City",
    "62":     "West Elsdon",
    "63":     "Gage Park",
    "64":     "Clearing",
    "65":     "West Lawn",
    "66":     "Chicago Lawn",
    "67":     "West Englewood",
    "68":     "Englewood",
    "69":     "Greater Grand Crossing",
    "70":     "Ashburn",
    "71":     "Auburn Gresham",
    "72":     "Beverly" ,
    "73":     "Washington Heights",
    "74":     "Mount Greenwood",
    "75":     "Morgan Park",
    "76":     "O'Hare",
    "77":     "Edgewater"
}