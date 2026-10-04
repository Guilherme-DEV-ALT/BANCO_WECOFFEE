# We Coffee — Modelo Conceitual de Banco de Dados

# Integrantes 

| Integrantes |
|---|
| Guilherme Souza Lima |
| João Victor Moidano do Valle |
| Gabriel Amorim Sartori |
| Guilherme Cau Guateli |
| Matheus Fernandes Andrade |

## Entrega 1 — Modelo Conceitual (DER)

**Organização analisada:** We Coffee — MOONLIGHT COFFEE CAFETERIA LTDA.  
**Unidade:** Av. Paulista, 1111 — Bela Vista, São Paulo/SP  
**Segmento:** Cafeteria, alimentos e bebidas

> Este README apresenta o levantamento de requisitos, processos de negócio, regras, dicionário de dados, modelagem conceitual, DER e justificativas técnicas do projeto.

---

# 1. Caracterização da Organização

## Nome e natureza da organização

A organização escolhida é a **MOONLIGHT COFFEE CAFETERIA LTDA.**, que utiliza o nome comercial **We Coffee**. A We Coffee atua no segmento de cafeterias, com comercialização de alimentos e bebidas e uma proposta de experiência diferenciada para os clientes.
**Site:** https://wecoffee.com.br/  
**Unidade analisada:** Avenida Paulista, 1111 — Bela Vista, São Paulo/SP.

##  Contexto e porte

A unidade analisada possui aproximadamente **6 funcionários** e trabalha com diferentes formas de atendimento:

- **Totem de autoatendimento:** o próprio cliente realiza o pedido e o pagamento.
- **Balcão:** o funcionário registra o pedido e informa o nome do cliente.
- **Aplicativo:** o cliente realiza o pedido e o pagamento pela própria plataforma.
Após o registro do pedido, é gerada uma comanda para auxiliar no processo de preparação e entrega.

## Problemas e necessidades identificados

Durante a entrevista com a gerente da unidade, foi identificado que as informações de vendas podem ser consultadas, porém tem uma certa dificuldade para **consolidar essas informações em um fechamento mensal que permita avaliar claramente o desempenho da loja**.

Também foi observado que o controle de disponibilidade dos produtos depende da atualização do estoque. Quando um produto acaba, a equipe verifica a situação e atualiza sua disponibilidade para que os canais de venda reflitam a informação.

Dessa forma, o projeto busca estruturar os dados de pedidos, pagamentos, produtos, estoque e entradas de estoque para facilitar consultas e futuras análises gerenciais.

## justificativa da escolha

A We Coffee foi escolhida por apresentar um cenário real de operação comercial com diferentes canais de atendimento, vendas, pagamentos, controle de estoque e relacionamento com fornecedores. Sendo também uma empresa nova com apenas 5 anos com obejtivos de finalizar o ano com 20 unidades no total e parecendo ser uma execelente oportunidade para aprendermos e crescermos junto com a empresa. 

O grupo teve acesso à unidade e realizou entrevista com a gerente, além de observação dos processos e registros fotográficos.

## Evidências da organização

Foram obtidas evidências da existência e do acesso à organização, incluindo:

- endereço da unidade;
- site oficial;
- rede social da organização;
- entrevista com a gerente;
- registros fotográficos da unidade.
- vídeos de como funciona o atendimenmto.
- como os atendimento é processado
- Link da loja: https://share.google/shs5jxNxnNAmYuQjz 

---

# 2. Processos de Negócio

## Principais processos mapeados

Foram identificados os seguintes processos:

- **Atendimento e realização do pedido:** pedido realizado pelo totem, balcão ou aplicativo.
- **Pagamento:** registro do pagamento correspondente ao pedido, inclusive quando a conta é dividida.
- **Preparação e entrega:** geração da comanda, preparação e identificação do cliente para entrega.
- **Controle de disponibilidade:** verificação do estoque e atualização da disponibilidade dos produtos.
- **Reposição de estoque:** solicitação, recebimento e registro das entradas de produtos.
- **Consulta e análise de vendas:** consolidação das informações para apoiar o fechamento mensal e a análise do desempenho da unidade.

## Fluxograma


### Legenda

| Elemento | Significado |
|---|---|
| 🟢| Início / Fim |
| ▭ | Processo / Atividade |
| ♦️| Decisão |
| Setas | Fluxo de execução |

---

# 3. Requisitos do Sistema

## 3.1Requisitos Funcionais

| Requisito | Entidade e associação |
|---|---|
| O sistema deve permitir cadastrar clientes. | CLIENTE — identificado por CPF/CNPJ e associado a PEDIDO. |
| O sistema deve permitir cadastrar funcionários. | FUNCIONARIO — identificado por ID/CPF e associado à UNIDADE e aos pedidos. | 
| O sistema deve permitir cadastrar totens. | TOTEM — identificado por ID e associado à UNIDADE e aos pedidos. |
| O sistema deve permitir cadastrar produtos. | PRODUTO — identificado por ID e associado a ITEM_PEDIDO e ITEM_ENTRADA_ESTOQUE.|
| O sistema deve permitir registrar pedidos. | PEDIDO — identificado por ID e associado a CLIENTE, ITEM_PEDIDO e PAGAMENTO. |
| O sistema deve identificar o canal de realização do pedido: TOTEM, BALCÃO ou APLICATIVO. | PEDIDO — possui o atributo CANAL_PEDIDO, identificando a origem da venda. |
| O sistema deve permitir registrar os produtos e quantidades de cada pedido. | ITEM_PEDIDO — associa PEDIDO e PRODUTO, registrando quantidade.|
| O sistema deve registrar o preço praticado no momento da venda. | ITEM_PEDIDO — registra o PREÇO_UNITARIO no momento da venda.|
| O sistema deve permitir registrar um ou mais pagamentos para um pedido. | PAGAMENTO — identificado por ID e associado a PEDIDO. |
| O sistema deve permitir registrar pagamentos divididos entre diferentes formas de pagamento. | PAGAMENTO — registra valor e FORMA_PAGAMENTO, permitindo divisão. |
| O sistema deve permitir consultar a quantidade disponível de cada produto. | ESTOQUE — associado a PRODUTO e registra a quantidade disponível. |
| O sistema deve permitir registrar entradas de estoque. | ENTRADA_ESTOQUE — associada a FORNECEDOR e ITEM_ENTRADA_ESTOQUE. |
| O sistema deve permitir cadastrar fornecedores. | FORNECEDOR — identificado por CNPJ e associado a ENTRADA_ESTOQUE. |
| O sistema deve registrar os produtos e quantidades recebidos em cada entrada de estoque. | ITEM_ENTRADA_ESTOQUE — associa ENTRADA_ESTOQUE e PRODUTO, registrando quantidade. |
| O sistema deve permitir consultar pedidos e pagamentos. | PEDIDO — associado a PAGAMENTO, permitindo consultar valores e formas de pagamento. |
| O sistema deve permitir consolidar informações de vendas para apoiar o fechamento mensal. | PEDIDO + ITEM_PEDIDO + PAGAMENTO — associados para consolidar vendas e valores mensais. |

## 3.2 Requisitos Não Funcionais

| Requisito |
|---|
| **Usabilidade:** as informações devem ser apresentadas de forma clara e organizada. |
| **Integridade:** os relacionamentos entre pedidos, produtos, pagamentos e estoque devem permanecer consistentes. |
| **Segurança:** informações administrativas e financeiras devem possuir controle de acesso adequado. |
| **Desempenho:** consultas de pedidos, estoque e vendas devem apresentar resposta adequada à operação. |
| **Disponibilidade:** as informações necessárias à operação devem estar disponíveis quando forem necessárias. |
| **Escalabilidade:** o modelo deve permitir o crescimento da quantidade de produtos, pedidos, funcionários e fornecedores. |

---

# 4. Regras de Negócio

## 4.1 Regras Operacionais

| Regras |
|---|
| Todo pedido deve possuir um identificador único. |
| Todo pedido deve possuir pelo menos um item. | 
| A quantidade de um item de pedido deve ser maior que zero. |
| Cada item de pedido deve estar associado a um produto cadastrado. |
| O preço unitário registrado no item deve representar o valor praticado no momento da venda. |
| Um pedido pode possuir mais de um pagamento para permitir divisão da conta. |
| Cada pagamento deve registrar o valor correspondente àquela forma de pagamento. |
| A quantidade disponível no estoque não pode ser negativa. |
| Toda entrada de estoque deve registrar fornecedor, data e produtos recebidos. |
| A quantidade recebida de um produto deve ser maior que zero. |
| Cada pedido deve possuir um canal: TOTEM, BALCÃO ou APLICATIVO. |
| Pedido realizado pelo totem deve possuir referência ao totem utilizado. |
| Pedido realizado no balcão deve possuir referência ao funcionário responsável pelo registro. |
| Pedido realizado pelo aplicativo não precisa estar associado a funcionário ou totem da unidade. |
| O cliente pode não possuir cadastro completo no momento do pedido. |
| CPF/CNPJ do cliente é opcional. |

## 4.2 Restrições Organizacionais

| Restrição | Impacto no modelo |
|---|---|
| Atualmente existe um fornecedor principal, mas outros fornecedores podem ser utilizados quando houver necessidade e autorização. | O modelo permite cadastrar múltiplos fornecedores. |
| O estoque é controlado individualmente por produto. | Cada produto possui um registro de estoque. |
| A unidade registra quantidade e data das entradas de estoque. | Foram criadas ENTRADA_ESTOQUE e ITEM_ENTRADA. |
| Não foi identificado controle individual de validade no processo levantado. | O atributo de validade não foi incluído no modelo. |
| O aplicativo utiliza sua própria plataforma e entrada de pedidos. | O pedido é identificado pelo canal APLICATIVO, sem associação obrigatória a totem ou funcionário. |
| O sistema existente possui relação com o ambiente TOTVS. | O modelo proposto representa os dados levantados e não assume a substituição do sistema existente. |

---

# 5. Dicionário de Dados Conceitual

## 5.1 Entidade: CLIENTE

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_cliente | Identificador único do cliente | Obrigatório e único (PK) |
| nome | Nome do cliente | Obrigatório |
| cpf_cnpj | CPF ou CNPJ informado pelo cliente | Opcional; quando informado, deve ser único |

## 5.2 Entidade: FUNCIONARIO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_funcionario | Identificador único do funcionário | Obrigatório e único (PK) |
| nome | Nome do funcionário | Obrigatório |
| cargo | Função exercida pelo funcionário | Obrigatório |

## 5.3 Entidade: TOTEM

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_totem | Identificador único do totem | Obrigatório e único (PK) |
| identificador_tablet | Identificação do equipamento | Obrigatório e único |
| localizacao_loja | Localização do equipamento na unidade | Obrigatório |
| status | Situação do equipamento | Obrigatório |

## 5.4 Entidade: PEDIDO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_pedido | Identificador único do pedido | Obrigatório e único (PK) |
| id_cliente | Cliente relacionado ao pedido | Opcional (FK) |
| id_funcionario | Funcionário responsável pelo pedido de balcão | Condicional (FK) |
| id_totem | Totem utilizado no pedido | Condicional (FK) |
| data_hora | Data e horário do registro | Obrigatório |
| canal_pedido | Canal utilizado para realizar o pedido | Obrigatório: TOTEM, BALCÃO ou APLICATIVO |
| valor_total | Valor total do pedido | Obrigatório; calculado a partir dos itens |
| status_preparo | Situação do pedido durante a preparação | Obrigatório |

## 5.5 Entidade: ITEM_PEDIDO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_item | Identificador único do item | Obrigatório e único (PK) |
| id_pedido | Pedido ao qual o item pertence | Obrigatório (FK) |
| id_produto | Produto associado ao item | Obrigatório (FK) |
| id_quantidade | Quantidade do produto vendida | Obrigatório; maior que zero |
| preco_unitario | Preço do produto no momento da venda | Obrigatório; preserva o histórico |

## 5.6 Entidade: PRODUTO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_produto | Identificador único do produto | Obrigatório e único (PK) |
| nome | Nome do produto | Obrigatório |
| preco | Preço atual de venda | Obrigatório; maior que zero |

## 5.7 Entidade: PAGAMENTO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_pagamento | Identificador único do pagamento | Obrigatório e único (PK) |
| id_pedido | Pedido relacionado ao pagamento | Obrigatório (FK) |
| forma_pagamento | Forma utilizada no pagamento | Obrigatório: PIX, Crédito, Débito ou Dinheiro |
| valor_pagamento | Valor correspondente ao pagamento | Obrigatório; maior que zero |
| status_pagamento | Situação do pagamento | Obrigatório: Aprovado ou Recusado |
| data_hora_pagamento | Data e horário do pagamento | Obrigatório |

## 5.8 Entidade: ESTOQUE

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_estoque | Identificador único do estoque | Obrigatório e único (PK) |
| id_produto | Produto controlado pelo estoque | Obrigatório e único (FK) |
| Quantidade | Quantidade atual disponível | Obrigatório; maior ou igual a zero |
| data_atualizacao | Data da última atualização | Obrigatório |

## 5.9 Entidade: FORNECEDOR

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_fornecedor | Identificador único do fornecedor | Obrigatório e único (PK) |
| nome | Nome do fornecedor | Obrigatório |

## 5.10 Entidade: ENTRADA_ESTOQUE

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_entrada | Identificador único da entrada | Obrigatório e único (PK) |
| id_fornecedor | Fornecedor relacionado à entrada | Obrigatório (FK) |
| data_entrada | Data de recebimento dos produtos | Obrigatório |

## 5.11 Entidade: ITEM_ENTRADA

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_item_entrada | Identificador único do item da entrada | Obrigatório e único (PK) |
| id_entrada | Entrada de estoque relacionada | Obrigatório (FK) |
| id_produto | Produto recebido | Obrigatório (FK) |
| quantidade | Quantidade recebida do produto | Obrigatório; maior que zero |

---

# 6. Modelagem Conceitual

## 6.1 Entidades reconhecidas

| Entidade | Justificativa |
|---|---|
| CLIENTE | Representa o cliente relacionado aos pedidos quando houver identificação. |
| FUNCIONARIO | Representa os funcionários que registram pedidos realizados no balcão. |
| TOTEM | Representa os equipamentos utilizados para autoatendimento. |
| PEDIDO | Representa a realização de uma compra em um dos canais disponíveis. |
| ITEM_PEDIDO | Representa cada produto e quantidade pertencentes a um pedido. |
| PRODUTO | Representa os alimentos e bebidas comercializados. |
| PAGAMENTO | Registra os pagamentos associados aos pedidos, inclusive pagamentos divididos. |
| ESTOQUE | Controla a quantidade disponível de cada produto. |
| FORNECEDOR | Representa os fornecedores utilizados para reposição. |
| ENTRADA_ESTOQUE | Representa cada recebimento de produtos no estoque. |
| ITEM_ENTRADA | Representa os produtos e quantidades presentes em cada entrada de estoque. |

## 6.2 Atributos e classificações

Os atributos foram definidos a partir dos processos observados e estão detalhados no Dicionário de Dados da Seção 5.

Foram classificados principalmente como:

- **PK:** identificadores únicos das entidades;
- **FK:** atributos utilizados para relacionar entidades;
- **Obrigatórios:** informações necessárias para o registro;
- **Opcionais:** informações que podem não ser fornecidas;
- **Condicionais:** atributos utilizados conforme o canal do pedido;
- **Calculados:** informações derivadas de outros registros.

## 6.3 Relacionamentos pertinentes

| Relacionamento | Descrição | Cardinalidade |
|---|---|---|
| CLIENTE — PEDIDO | Um cliente pode realizar vários pedidos. | 1:N |
| FUNCIONARIO — PEDIDO | Um funcionário pode registrar vários pedidos de balcão. | 1:N |
| TOTEM — PEDIDO | Um totem pode registrar vários pedidos. | 1:N |
| PEDIDO — ITEM_PEDIDO | Um pedido possui um ou mais itens. | 1:N |
| PRODUTO — ITEM_PEDIDO | Um produto pode aparecer em vários itens de pedidos. | 1:N |
| PEDIDO — PAGAMENTO | Um pedido pode possuir um ou mais pagamentos. | 1:N |
| PRODUTO — ESTOQUE | Cada produto possui um registro de estoque. | 1:1 |
| FORNECEDOR — ENTRADA_ESTOQUE | Um fornecedor pode estar associado a várias entradas. | 1:N |
| ENTRADA_ESTOQUE — ITEM_ENTRADA | Uma entrada pode possuir vários produtos. | 1:N |
| PRODUTO — ITEM_ENTRADA | Um produto pode aparecer em várias entradas. | 1:N |

## 6.4 Restrições aplicadas ao modelo

- O canal do pedido deve ser TOTEM, BALCÃO ou APLICATIVO.
- `id_totem` é utilizado quando o canal é TOTEM.
- `id_funcionario` é utilizado quando o canal é BALCÃO.
- Pedidos do APLICATIVO não precisam de funcionário ou totem.
- Um pedido pode possuir múltiplos pagamentos para representar divisão da conta.
- Um produto possui um único registro de estoque atual.
- Uma entrada de estoque pode conter diversos produtos por meio de ITEM_ENTRADA.
- Não foi incluído controle individual de validade porque essa necessidade não foi identificada no levantamento.

---

# 7. Diagrama Entidade-Relacionamento (DER)

## 7.1 DER da We Coffee
[text](../WeCoffee_BRModelo.pdf)

## 7.2 Principais relacionamentos

| Entidade A | Relacionamento | Entidade B | Cardinalidade |
|---|---|---|---|
| CLIENTE | realiza | PEDIDO | 1:N |
| FUNCIONARIO | registra | PEDIDO | 1:N |
| TOTEM | registra | PEDIDO | 1:N |
| PEDIDO | possui | ITEM_PEDIDO | 1:N |
| PRODUTO | compõe | ITEM_PEDIDO | 1:N |
| PEDIDO | possui | PAGAMENTO | 1:N |
| PRODUTO | possui | ESTOQUE | 1:1 |
| FORNECEDOR | realiza | ENTRADA_ESTOQUE | 1:N |
| ENTRADA_ESTOQUE | possui | ITEM_ENTRADA | 1:N |
| PRODUTO | aparece em | ITEM_ENTRADA | 1:N |

### Observação sobre PEDIDO e PRODUTO

A relação conceitual entre **PEDIDO** e **PRODUTO** é de muitos-para-muitos, pois um pedido pode conter vários produtos e um produto pode aparecer em vários pedidos.

No DER, essa relação é representada por meio da entidade associativa **ITEM_PEDIDO**:

**PEDIDO 1:N ITEM_PEDIDO N:1 PRODUTO**

### Observação sobre pagamentos

A relação **PEDIDO — PAGAMENTO** foi definida como **1:N** porque uma conta pode ser dividida em diferentes formas de pagamento.

---

# 8. Justificativa Técnica

## 8.1 Decisões de abstração e modelagem

| Decisão | Justificativa |
|---|---|
| Escolha das entidades | Foram selecionadas entidades diretamente relacionadas aos processos observados na unidade: atendimento, pedidos, pagamentos, produtos, estoque e fornecedores. |
| PEDIDO como entidade central | O pedido conecta o processo de venda aos clientes, canais, itens e pagamentos. |
| ITEM_PEDIDO como entidade associativa | Resolve a relação N:M entre pedidos e produtos e permite registrar quantidade e preço histórico. |
| PAGAMENTO separado de PEDIDO | Permite representar mais de uma forma de pagamento no mesmo pedido. |
| `valor_pagamento` | Necessário para registrar quanto foi pago em cada parte quando a conta é dividida. |
| `canal_pedido` | Permite diferenciar TOTEM, BALCÃO e APLICATIVO sem criar uma entidade artificial para cada canal. |
| FUNCIONARIO e TOTEM opcionais/condicionais em PEDIDO | Cada um é utilizado de acordo com o canal do pedido. |
| ESTOQUE separado de PRODUTO | Evita duplicar a informação de quantidade disponível dentro do cadastro do produto. |
| ENTRADA_ESTOQUE e ITEM_ENTRADA | Permitem registrar a data de recebimento e quais produtos/quantidades foram recebidos. |
| FORNECEDOR separado | Permite representar o fornecedor atual e possibilita cadastrar outros fornecedores futuramente. |

## 8.2 Por que não outras alternativas?

| Alternativa | Motivo da rejeição |
|---|---|
| Manter `qtd_estoque` dentro de PRODUTO e também em ESTOQUE | Criaria duas fontes para a mesma informação de quantidade e poderia gerar inconsistência. |
| Relacionar PEDIDO diretamente com PRODUTO sem ITEM_PEDIDO | Não permitiria representar corretamente quantidade e preço histórico de cada produto vendido. |
| PEDIDO 1:1 PAGAMENTO | Não representaria a possibilidade de dividir a conta entre diferentes formas de pagamento. |
| Criar uma entidade APLICATIVO | O levantamento identificou o aplicativo como um canal/plataforma externa de pedido, e não como uma entidade de negócio necessária ao modelo atual. |
| Criar controle de validade | A necessidade não foi identificada no processo observado, pois os produtos expostos são repostos diariamente. |
| Limitar o modelo a apenas um FORNECEDOR | Embora exista atualmente um fornecedor principal, a organização pode utilizar outros fornecedores quando necessário. |

## 8.3 Justificativa do DER

O DER foi elaborado para representar os principais processos da unidade da We Coffee de forma integrada.

A entidade PEDIDO funciona como núcleo do processo de vendas, conectando clientes, funcionários, totens, itens e pagamentos. A utilização de ITEM_PEDIDO permite representar corretamente os produtos vendidos e preservar o preço praticado no momento da venda.

A estrutura de pagamentos permite que um pedido tenha mais de uma forma de pagamento, refletindo a possibilidade de divisão da conta.

O modelo de estoque foi separado do cadastro de produtos para evitar redundância e permitir o controle da quantidade atual. As entidades de entrada e fornecedor complementam esse processo ao registrar os recebimentos de produtos.

A modelagem também foi preparada para crescimento futuro, permitindo novos produtos, fornecedores, funcionários, totens, pedidos e entradas de estoque sem alterar a estrutura principal.

---

# 9. Uso de Inteligência Artificial

A Inteligência Artificial foi utilizada como ferramenta de apoio durante o desenvolvimento do projeto.

| Item | Registro |
|---|---|
| **Ferramenta e etapa** | ChatGPT *GPT-5.6 Luna*, utilizado na organização do README, análise dos requisitos, revisão do modelo conceitual, definição de cardinalidades e estruturação do dicionário de dados. |
| **Motivação** | Auxiliar na organização das informações levantadas e revisar a consistência entre processos, requisitos, regras, entidades e relacionamentos. |
| **Prompts utilizados** | Exemplos: "Com base no levantamento realizado na We Coffee, identifique as entidades necessárias para o modelo conceitual."; "Com base nesses dois veja se bate o que está sendo pedido, esse ultimo que te mandei foi um exemplo de um amigo meu e veja o que o dele está certo e nosso errado\nesse Prompt, utilizei o arquivo de esqueleto do professor, o nosso readme.md e outro readme.md de um amigo para ter um comparativo onde poderíamos melhor nosso trabalho.";"Revise o modelo considerando que um pedido pode ser dividido em dois pagamentos."; "Analise o controle de estoque e fornecedor e indique como representar isso no modelo conceitual."; "Faça um pente-fino no README verificando se os requisitos, regras, dicionário e DER estão coerentes." |
| **Resposta recebida** | A IA forneceu sugestões de estrutura, entidades, relacionamentos, cardinalidades, requisitos, regras e organização do documento. |
| **Fontes consultadas e verificadas** | As informações sobre os processos da organização foram comparadas com o levantamento realizado pelo grupo, incluindo entrevista e observação da unidade. |
| **Trechos rejeitados ou corrigidos** | Nem tudo que a IA sugeriu ficou no modelo final. O exemplo mais claro foi a cardinalidade entre PEDIDO e PAGAMENTO: a primeira sugestão veio como 1:1, o que simplesmente não bateria com o que vimos na loja — a divisão de conta é algo real e recorrente. Corrigimos para 1:N. Outro ponto ajustado foi a tentativa inicial de manter a quantidade em estoque tanto em PRODUTO quanto em ESTOQUE; percebemos que isso duplicaria a informação e resolvemos manter só em ESTOQUE. |
| **Justificativa da escolha final** | As decisões finais foram tomadas pelo grupo com base nas informações obtidas na organização e na necessidade de manter coerência entre o modelo e os processos observados. |
| **Reflexão crítica** | De modo geral, a IA ajudou a organizar as ideias e a apontar inconsistências que a gente não tinha notado, mas todas as decisões finais passaram pela validação do grupo com base no que foi observado e coletado na visita e na entrevista — a IA sugeriu, mas quem decidiu foi o grupo mesmo. |

---
- **Participação (10%):** envolvimento nas discussões técnicas e nas decisões do grupo.
- **Comprometimento (8%):** cumprimento de prazos e responsabilidades assumidas.
- **Colaboração (4%):** respeito às contribuições dos colegas, cooperação na construção do projeto e colaboração equilibrada no histórico de commits do repositório GitHub.
- **Autonomia (7%):** busca independente de soluções e proposta de melhorias.
