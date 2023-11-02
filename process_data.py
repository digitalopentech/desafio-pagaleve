import json
import boto3

s3_client = boto3.client('s3')
BUCKET_NAME = 'teste-projeto-aws-20231027185708'
KEY_PREFIX = 'orders/'

def lambda_handler(event, context):
    for record in event['Records']:
        new_image = record['dynamodb']['NewImage']
        print(new_image)  # Adicionando print para debug

        processed_data = {
            "orderId": new_image.get("orderId", {}).get("N", "Default_Value_OrderId"),  # Lidando com chaves faltantes
            "merchantId": new_image.get("merchantId", {}).get("S", "Default_Value_MerchantId"),
            "customerId": new_image.get("customerId", {}).get("S", "Default_Value_CustomerId"),
            "status": new_image.get("status", {}).get("S", "Default_Value_Status"),
        }

        processed_data_str = json.dumps(processed_data)

        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=f'{KEY_PREFIX}{record["eventID"]}.json',
            Body=processed_data_str
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Data processed and stored in S3!')
    }
