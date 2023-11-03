import boto3

# Configurações
redshift_cluster_identifier = "redshift-cluster-1"
database_name = "mydb"
user_name = "admin"
password = "Red$hiftSecure!2023-PipeLines"
query = """
    COPY orders
    FROM 's3://teste-projeto-aws-20231027185708/orders/'
    ACCESS_KEY_ID 'AKIAWFQCSSXHZDRXROHI'
    SECRET_ACCESS_KEY '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'
    JSON 'auto';
"""

# Criação do cliente Redshift
client = boto3.client('redshift')

# Obtenção do endpoint do cluster Redshift
response = client.describe_clusters(ClusterIdentifier=redshift_cluster_identifier)
cluster_endpoint = response['Clusters'][0]['Endpoint']['Address']

# Conexão com o Redshift e execução do comando COPY
import psycopg2
conn = psycopg2.connect(
    host=cluster_endpoint,
    dbname=database_name,
    user=user_name,
    password=password,
    port='5439'
)
cur = conn.cursor()
cur.execute(query)
conn.commit()
cur.close()
conn.close()
