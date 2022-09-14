# Banco de Dados: Orçamento Agropecuária

## Exercício complementar

Uma empresa de venda de produtos agropecuários necessita de um software para gerenciar orçamentos. Todos os orçamentos serão efetuados no sistema para cada orçamento os produtos de interesse do cliente, quantidade e preço definido para cada item devem ser cadastrados, a forma do parcelamento “quantidade de parcelas”, para cada orçamento existe um prazo de validade, e uma data de aprovação, o orçamento não pode ser aprovado após a data de validade do mesmo, quando um orçamento é aprovado é gerado uma venda com os dados do orçamento, os itens orçados são lançados em itens vendidos e é gerado a parcelas de pagamento da venda.

O sistema deve contemplar um caixa também que é aberto e fechado diariamente uma única vez, para efetuar o pagamento de uma parcela esse caixa deve existir e estar aberto caso ele esteja fechado deve ser informado e o pagamento cancelado, caso não exista deve ser gerado um caixa em estado aberto para a data corrente e o valor pago deve ser acumulado em um atributo entrada.

Todo orçamento possui um nome de cliente e telefone, caso essa pessoa não seja um cliente da empresa ao ser aprovado o orçamento esta pessoa deve ser incluída na tabela de clientes informando os dados que estão disponíveis no orçamento o restante pode ficar em branco.

Crie uma modelagem e a base de dados, que atenda ao problema acima que contemple o gerenciamento dos orçamentos, venda e pagamento.

Otimize a base de dados criando triggers que gere a venda por inteiro após o orçamento ser aprovado gerando a venda, itens de venda e os pagamentos, atualize o caixa e insira os clientes.

**Faça:**

1. Faça a modelagem
2. Crie a base de dados de acordo com modelo
3. Crie o schema orçamento
4. Crie um script de todos os comandos para criar estrutura, trigger, funções e procedures
5. Crie um script somente dos testes efetuados, junto com as inserções, updates e deletes
