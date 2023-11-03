import json
import boto3

s3_client = boto3.client('s3')
BUCKET_NAME = 'teste-projeto-aws-20231027185799'
KEY_PREFIX = 'orders/'

def lambda_handler(event, context):
    for record in event['Records']:
        new_image = record['dynamodb']['NewImage']
        
        # Log para depuração
        print(new_image)

        # Assegura que o 'orderid' é uma string se presente, caso contrário usa um valor padrão.
        order_id = new_image.get("orderid", {}).get("S", "Default_Value_OrderId")

        processed_data = {
            "orderid": order_id,
            "merchantid": new_image.get("merchantid", {}).get("S", "Default_Value_MerchantId"),
            "customerid": new_image.get("customerid", {}).get("S", "Default_Value_CustomerId"),
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