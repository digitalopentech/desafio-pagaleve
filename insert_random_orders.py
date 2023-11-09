import boto3
import random
import string

# Inicializar um cliente DynamoDB usando o boto3
dynamodb = boto3.resource('dynamodb')

# Escolher a tabela
table = dynamodb.Table('OrdersTable')

# Função para gerar um ID de pedido aleatório
def generate_order_id(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

# Função para inserir um item na tabela
def insert_random_order():
    order_id = generate_order_id()
    customer_id = "C54321"
    merchant_id = "M12345"
    status = "SHIPPED"
    
    item = {
        'orderid': order_id,
        'customerid': customer_id,
        'merchantid': merchant_id,
        'status': status
    }

    response = table.put_item(Item=item)
    return item

# Insere 10 ordens aleatórias
for _ in range(10):
    item = insert_random_order()
    print(f"Inserted order with ID: {item['orderid']}")

if __name__ == "__main__":
    # A função abaixo foi removida do if para inserir 10 ordens como descrito acima
    # insert_random_order()
    pass
