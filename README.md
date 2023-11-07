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

Desenho de Arquitetura:
VPC (Virtual Private Cloud): Isola recursos em uma rede virtual privada. É a base da infraestrutura de rede na AWS.

Subnets: Segmentos da VPC que permitem organizar recursos em blocos de rede separados.

S3 Bucket: Armazenamento escalável e de alta disponibilidade para qualquer tipo de dados. É usado para armazenar dados de entrada/saída para processamento.

DynamoDB Table: Banco de dados NoSQL para armazenar e recuperar qualquer quantidade de dados. Ele é usado para armazenar pedidos com capacidade de leitura e escrita provisionada.

IAM Role e Policies: Controlam as permissões para serviços da AWS interagirem entre si. No seu caso, são usadas para dar à função Lambda acesso ao S3, DynamoDB Streams e CloudWatch Logs.

Lambda Functions:

process_orders: Função para processar pedidos, provavelmente ativada pelo DynamoDB Streams.
process_json_to_redshift: Função para processar arquivos JSON e mover os dados para o Redshift.
Redshift Cluster: Serviço de data warehousing, que permite executar consultas complexas em grandes conjuntos de dados e é usado para análises.

S3 Bucket Notifications e Lambda Triggers: Configurados para acionar funções Lambda com base em eventos específicos, como a criação de objetos no S3.

Benefícios de Cada Tecnologia:
AWS VPC: Provê um ambiente isolado na nuvem para hospedar seus recursos, melhorando a segurança e facilitando a gestão da rede.

Subnets: Permitem a segmentação de recursos e controle de tráfego para melhor desempenho e segurança.

S3 Bucket: Oferece durabilidade, disponibilidade e escalabilidade para armazenamento de dados, suportando diversas cargas de trabalho de dados.

DynamoDB: Oferece desempenho rápido e previsível com escalabilidade automática e suporte para modelos de dados flexíveis.

IAM Role e Policies: Essencial para a segurança de identidade e acessos, assegurando que apenas entidades autorizadas possam realizar operações específicas.

Lambda Functions: Permitem a execução de código em resposta a eventos, sem a necessidade de provisionar ou gerenciar servidores, facilitando operações e reduzindo custos.

Redshift: Facilita análises rápidas e complexas de grandes conjuntos de dados, fornecendo insights de negócios valiosos.

S3 Bucket Notifications e Lambda Triggers: Automatizam o workflow de processamento de dados ao reagir a eventos de criação de arquivos, tornando o sistema mais eficiente e responsivo.

A arquitetura descrita é fortemente orientada a eventos, aproveitando as capacidades serverless da AWS para processamento de dados em tempo real e análise. Cada tecnologia é escolhida por sua escalabilidade, desempenho e facilidade de integração em um ecossistema AWS.
