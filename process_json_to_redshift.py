import json
import boto3
import os
from typing import Dict

def lambda_handler(event, context):
    s3_client = boto3.client('s3')
    redshift_data_client = boto3.client('redshift-data')

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get the JSON file content
        file_obj = s3_client.get_object(Bucket=bucket_name, Key=key)
        file_content = file_obj['Body'].read().decode('utf-8')
        json_content = json.loads(file_content)

        # Aqui você processaria e transformaria seus dados conforme necessário
        # ...

        # Inserir dados no Redshift
        insert_statement = "INSERT INTO your_table_name (...) VALUES (...)"
        redshift_data_client.execute_statement(
            ClusterIdentifier=os.environ['REDSHIFT_CLUSTER_IDENTIFIER'],
            DbUser=os.environ['REDSHIFT_USER'],
            Database=os.environ['REDSHIFT_DATABASE'],
            Sql=insert_statement
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
