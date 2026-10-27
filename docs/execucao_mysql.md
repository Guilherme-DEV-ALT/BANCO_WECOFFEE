# Execução do banco de demonstração

SGBD: MySQL 8.0.16 ou superior, com InnoDB e CHECK aplicado. Validação realizada no MySQL 8.4.13 para Windows, em instância temporária local. Não foi instalado serviço permanente nem colocado MySQL dentro deste repositório.

## Antes de executar

Use um banco de demonstração. O script cria o schema dedicado wecoffee_entrega2_demo e não contém DROP DATABASE. Se esse nome já existir, CREATE DATABASE falha: use outra instância vazia ou altere consistentemente o nome do schema nos scripts antes de executar. Não ignore o erro e não execute com --force sobre uma base existente.

## Cliente mysql

Abra o cliente mysql com seu usuário e a senha apropriada ao seu ambiente. A senha não está em nenhum arquivo do projeto. No prompt do cliente, a partir da raiz do repositório:

~~~sql
SOURCE docs/script.sql;
SOURCE docs/testes_integridade.sql;
~~~

No Windows, se o diretório de trabalho for outro, use caminhos absolutos com barras, por exemplo:

~~~sql
SOURCE C:/Users/User/Documents/BANCO_WECOFFEE/docs/script.sql;
~~~

O arquivo utiliza DELIMITER para rotinas e triggers. No MySQL Workbench, abra e execute o script completo, mantendo os delimitadores. Os INSERTs da massa já fazem parte de script.sql; não há carga externa a executar duas vezes.

## Resultado esperado da carga original

Dez tabelas, 44 colunas e nove FKs. A carga tem 120 pedidos, 270 linhas em pedido_produto, 120 cupons, 165 tentativas, três recebimentos e 14 linhas em entrada_produto, além dos cadastros. G01 retorna 33, 33 e 32 pedidos quitados em julho, agosto e setembro de 2026, com R$1.437,00, R$1.428,50 e R$1.395,50. São resultados de dados fictícios.

A04 retorna uma divergência intencional de R$0,01 no pedido 120. Esse pedido continua RECEBIDO e não pode avançar ao preparo. As demais auditorias devem retornar vazio. G08 retorna produtos abaixo do mínimo, permitindo demonstrar a consulta.

Os 31 testes devem retornar PASS. A tabela temporária de resultados usa MEMORY para preservar a evidência de asserções feitas antes de ROLLBACK. Os testes positivos revertem a operação; tentativas inválidas com criação transacional devem deixar o banco sem pedidos parciais. AUTO_INCREMENT pode apresentar lacunas após rejeições e rollback; isso não altera as contagens de linhas.

## Operações controladas

- Criar pedido: sp_criar_pedido recebe os dados do pedido, um array JSON de produtos e um array JSON de tentativas; publica pedido, linhas, cupom e tentativas em uma transação. JSON é formato de entrada, não armazenamento em listas.
- Registrar entrada: sp_registrar_entrada recebe fornecedor, data e produtos/quantidades e atualiza o saldo.
- Cancelar: sp_cancelar_pedido aplica a transição e devolve as unidades se o pedido ainda estava RECEBIDO e havia baixa. Depois de iniciado o preparo, quantidade_devolvida exige confirmação física por produto.
- Estornar: somente após confirmação financeira, atualizar A para E no pagamento de pedido CANCELADO. A transição preserva forma, valor, cupom e data originais.
- Novas tentativas: inserir nova linha de pagamento no cupom do pedido RECEBIDO. Recusas não apagam linhas nem desfazem aprovações.

O UPDATE e o DELETE de demonstração usam transações revertidas. O DELETE atua em um cadastro descartável sem vínculos, e não em um pedido ou pagamento histórico.

## Limitações e confirmação externa

A proposta implementa transações locais, não integração com adquirente, emissão fiscal oficial, autenticação ou permissões reais de produção. Uma confirmação financeira externa seguida de falha local exige conciliação de aplicação. Não há procedimento confirmado pela unidade para esse cenário.

A aplicação futura deve usar rotinas completas e privilégios mínimos. Escrita administrativa direta pode ignorar mínimos de participação ou alterar o saldo materializado; A01/A02/A03/A08/A11 detectam esses casos. Apenas rotinas e testes não equivalem a um controle de acesso implantado.

DATETIME segue a convenção de horário de São Paulo, sem conversão automática. Relatórios mensais usam o estado atual agrupado pela data do pedido. O modelo não tem datas de estorno/cancelamento/devolução nem todos os eventos para reconstruir um fechamento imutável. O saldo auditado é o atual; não se calcula estoque retroativo.

O dimensionamento real, os processos ainda não confirmados e os perfis/metas técnicas permanecem pendentes no README. Não há Python ou pasta tmp dentro do projeto.
