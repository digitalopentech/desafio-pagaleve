# desafio-pagaleve

Entendido, vou criar uma descrição detalhada do projeto com base no código Terraform fornecido.

---

# Projeto AWS com Pipeline de Processamento de Pedidos

## Introdução

Este projeto estabelece uma infraestrutura na AWS para processar pedidos de forma eficiente e escalável. A infraestrutura é baseada em vários serviços AWS, incluindo S3, DynamoDB, Lambda e Redshift, e é gerenciada usando o Terraform.

## Arquitetura

1. **VPC e Subnets**: Uma VPC principal é criada com duas subnets, fornecendo isolamento e segurança para os recursos provisionados.

2. **Bucket S3**: É criado um bucket S3 chamado `teste-projeto-aws-20231027185799`, que é usado para armazenar dados. O acesso a este bucket é privado por padrão.

3. **Tabela DynamoDB**: Uma tabela chamada `OrdersTable` é estabelecida no DynamoDB. Esta tabela armazenará os pedidos e terá streaming ativado. O streaming permitirá que os novos registros da tabela (ou alterações) sejam capturados em tempo real.

4. **Função Lambda**: A função Lambda chamada `process_orders` é configurada para processar pedidos. Ela tem permissões para:
    - Ler da stream do DynamoDB.
    - Escrever no bucket S3.
    - Registrar logs no CloudWatch.
    
   Assim que um pedido é inserido na tabela DynamoDB, a função Lambda é acionada automaticamente pela stream, processa o pedido e armazena os resultados no bucket S3.

5. **Cluster Redshift**: Um cluster Redshift é provisionado para análise de dados. Ele tem permissões para acessar dados do bucket S3, permitindo que os pedidos armazenados no S3 sejam analisados e consultados usando o Redshift.

## Fluxo de Processo (Pipeline)

1. **Inserção de Pedido**: Quando um pedido é inserido na tabela DynamoDB, ele dispara a stream associada.

2. **Processamento Lambda**: A stream do DynamoDB aciona a função Lambda, que processa o pedido.

3. **Armazenamento S3**: Após o processamento, os resultados são armazenados no bucket S3.

4. **Análise com Redshift**: Os dados armazenados no S3 podem ser carregados no Redshift para análises mais profundas e consultas SQL.

## Conclusão

Este projeto estabelece um pipeline robusto e escalável para processar pedidos usando uma combinação de serviços AWS. Ele garante que os pedidos sejam processados em tempo real, armazenados de forma segura e estejam disponíveis para análise usando ferramentas poderosas como o Redshift.
