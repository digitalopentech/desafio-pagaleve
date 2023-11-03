aws dynamodb put-item \
    --table-name OrdersTable \
    --item '{
        "orderId": {"S": "2"},
        "customerId": {"S": "C54321"},
        "merchantId": {"S": "M12345"},
        "status": {"S": "SHIPPED"}
    }' \
    --region us-west-2

