# We Coffee — Modelo Conceitual de Banco de Dados

# Integrantes

| Nome | RGM |
|----|----|
| Guilherme Souza Lima | 46899502 |
| João Victor Moidano do Valle | 46576461 |
| Gabriel Amorim Sartori | 46832939 |
| Guilherme Cau Guateli | 46736069 |
| Matheus Fernandes Andrade | 46754539 |

## Entrega 1 — Modelo Conceitual (DER)

**Organização analisada:** We Coffee — MOONLIGHT COFFEE CAFETERIA LTDA.
**Unidade:** Av. Paulista, 1111 — Bela Vista, São Paulo/SP
**Segmento:** Cafeteria, alimentos e bebidas

---

# 1. Caracterização da Organização

## Nome e natureza da organização

A organização escolhida é a **MOONLIGHT COFFEE CAFETERIA LTDA.**, que utiliza o nome comercial **We Coffee**. A We Coffee atua no segmento de cafeterias, com comercialização de alimentos e bebidas e uma proposta de experiência diferenciada para os clientes.
**CNPJ:** 34.706.031/0001-84
**Site:** https://wecoffee.com.br/
**Unidade analisada:** Avenida Paulista, 1111 — Bela Vista, São Paulo/SP.

## Contexto e porte

A unidade analisada possui aproximadamente **6 funcionários** e trabalha com diferentes formas de atendimento:

- **Totem de autoatendimento:** o próprio cliente realiza o pedido e o pagamento.
- **Balcão:** o funcionário registra o pedido e informa o nome do cliente.
- **Delivery:** o cliente realiza o pedido e o pagamento pela plataforma de entrega.
Após o registro do pedido, é gerada uma comanda para auxiliar no processo de preparação e entrega.

## Problemas e necessidades identificados

Durante a entrevista com o gerente da unidade, foi identificado que as informações de vendas podem ser consultadas, porém tem uma certa dificuldade para **consolidar essas informações em um fechamento mensal que permita avaliar claramente o desempenho da loja**.

Também foi observado que o controle de disponibilidade dos produtos depende da atualização do estoque. Quando um produto acaba, a equipe verifica a situação e atualiza sua disponibilidade para que os canais de venda reflitam a informação.

Dessa forma, o projeto busca estruturar os dados de pedidos, produtos, documentos fiscais e pagamentos para facilitar consultas e futuras análises gerenciais. O controle de estoque observado na unidade não integra o escopo desta versão do modelo.

## Justificativa da escolha

A We Coffee foi escolhida por apresentar um cenário real de operações comerciais com diferentes canais de atendimento, vendas, pagamentos, controle de estoque e relacionamento com fornecedores. Sendo também uma empresa nova com apenas 5 anos, com objetivos de finalizar o ano com 20 unidades no total e se mostrando ser uma excelente oportunidade para aprendermos e crescermos junto com a empresa.

O grupo teve acesso à unidade e realizou entrevista com o gerente, além de observação dos processos e registros fotográficos.

## Evidências da organização

Foram obtidas evidências da existência e do acesso à organização, incluindo:

- endereço da unidade;
- site oficial;
- rede social da organização;
- contato do gerente da unidade: Daniel Porrino (+55 11 95208-6022)
- entrevista com o gerente;
- registros fotográficos da unidade.
- vídeos de como funciona o atendimento.
- como os atendimento são processado
- Link da loja: https://share.google/shs5jxNxnNAmYuQjz

---

# 2. Processos de Negócio

## Principais processos mapeados

Foram identificados os seguintes processos:

- **Atendimento e realização do pedido:** pedido realizado pelo totem, balcão ou delivery, com a origem registrada em PEDIDO.
- **Emissão do documento fiscal:** todo pedido gera um CUPOM_FISCAL, que representa a nota fiscal do pedido neste modelo.
- **Pagamento:** o CUPOM_FISCAL gera os registros de pagamento, inclusive quando a conta é dividida.
- **Preparação e entrega:** geração da comanda, preparação e identificação do cliente para entrega.
- **Consulta e análise de vendas:** consolidação das informações para apoiar o fechamento mensal e a análise do desempenho da unidade.

## Fluxograma
![Fluxograma dos processos da We Coffee](<./WECOFFE/modelagem/drawio.jpg>)

### Legenda

| Elemento | Significado |
|---|---|
| 🟢| Início / Fim |
| ▭ | Processo / Atividade |
| ♦️| Decisão |
| Setas | Fluxo de execução |

---

# 3. Requisitos do Sistema

## 3.1 Requisitos Funcionais

Os requisitos funcionais são identificados pelo prefixo `RF` e os não funcionais pelo prefixo `RNF`. Os códigos existentes foram preservados; os códigos retirados não são reutilizados, mantendo a rastreabilidade das revisões. As regras de negócio referenciam esses códigos e as entidades documentadas na Seção 5.

| Código | Requisito | Entidade e associação |
|---|---|---|
| RF01 | O sistema deve permitir cadastrar clientes. | CLIENTE — identificado por `id_cliente` e associado a PEDIDO quando houver vínculo com um cliente cadastrado; `cpf_cnpj` é opcional. |
| RF02 | O sistema deve permitir cadastrar funcionários. | FUNCIONARIO — identificado por `id_funcionario` e associado aos pedidos de balcão. |
| RF04 | O sistema deve permitir cadastrar produtos. | PRODUTO — identificado por `id_produto` e associado a PEDIDO pelo relacionamento CONTÉM. |
| RF05 | O sistema deve permitir registrar pedidos. | PEDIDO — identificado por `id_pedido`, contém PRODUTO e gera CUPOM_FISCAL; CLIENTE é opcional e FUNCIONARIO é condicional à origem. |
| RF06 | O sistema deve identificar a origem do pedido: TOTEM, BALCÃO ou DELIVERY. | PEDIDO — `origem_pedido` identifica o canal e `totem` registra o equipamento utilizado quando a origem for TOTEM. |
| RF07 | O sistema deve permitir registrar os produtos e quantidades de cada pedido. | Relacionamento único PEDIDO — CONTÉM — PRODUTO, com o atributo `quantidade`. |
| RF08 | O sistema deve registrar o preço praticado no momento da venda. | Relacionamento PEDIDO — CONTÉM — PRODUTO — registra `preco_unitario`, preservando o preço praticado em cada venda. |
| RF09 | O sistema deve permitir registrar um ou mais pagamentos para o documento fiscal do pedido. | CUPOM_FISCAL — GERA — PAGAMENTO; cada pagamento referencia seu cupom por `id_cupom_fiscal`. |
| RF10 | O sistema deve permitir registrar pagamentos divididos entre diferentes formas de pagamento. | PAGAMENTO — registra `valor_pagamento` e `forma_pagamento`; os registros permanecem vinculados ao mesmo CUPOM_FISCAL. |
| RF13 | O sistema deve permitir cadastrar fornecedores. | FORNECEDOR — identificado por `id_fornecedor`, com o atributo `cnpj`; seu cadastro é preservado nesta versão. |
| RF15 | O sistema deve permitir consultar pedidos, documentos fiscais e pagamentos. | PEDIDO — GERA — CUPOM_FISCAL — GERA — PAGAMENTO. |
| RF16 | O sistema deve permitir consolidar informações de vendas para apoiar o fechamento mensal. | PEDIDO + CUPOM_FISCAL + PAGAMENTO — associados para consolidar vendas e valores mensais. |
| RF17 | O sistema deve permitir consultar a situação financeira do pedido pela soma dos pagamentos aprovados. | Os pagamentos são obtidos pelo CUPOM_FISCAL do pedido; a quitação é calculada conforme a Seção 4.1.1. |
| RF18 | O sistema deve permitir registrar o cancelamento de pedidos e o estorno dos pagamentos. | PEDIDO — `status_preparo` registra o cancelamento; PAGAMENTO — `status_pagamento` registra o estorno confirmado. |
| RF19 | O sistema deve permitir registrar o nome utilizado na comanda, mesmo sem cliente cadastrado, e identificar o pedido pelo número quando esse nome não for informado. | PEDIDO — `nome_comanda` registra o nome de chamada; na sua ausência, utiliza-se `id_pedido`, sem exigir associação a CLIENTE. |
| RF20 | O sistema deve gerar um documento fiscal para todo pedido. | PEDIDO — GERA — CUPOM_FISCAL, em uma relação 1:1; CUPOM_FISCAL representa a nota fiscal do pedido no modelo. |

## 3.2 Requisitos Não Funcionais

| Código | Requisito |
|---|---|
| RNF01 | **Usabilidade:** as informações devem ser apresentadas de forma clara e organizada. |
| RNF02 | **Integridade:** os relacionamentos entre pedidos, produtos, documentos fiscais e pagamentos devem permanecer consistentes. |
| RNF03 | **Segurança:** informações administrativas e financeiras devem possuir controle de acesso adequado. |
| RNF04 | **Desempenho:** consultas de pedidos, documentos fiscais e vendas devem apresentar resposta adequada à operação. |
| RNF05 | **Disponibilidade:** as informações necessárias à operação devem estar disponíveis quando forem necessárias. |
| RNF06 | **Escalabilidade:** o modelo deve permitir o crescimento da quantidade de produtos, pedidos, funcionários e fornecedores. |

---

# 4. Regras de Negócio

## 4.1 Regras Operacionais

| Regra | Requisitos relacionados |
|---|---|
| Todo pedido deve possuir um identificador único. | RF05, RNF02 |
| Todo pedido deve estar associado a pelo menos um produto cadastrado, por um único relacionamento CONTÉM entre PEDIDO e PRODUTO. | RF04, RF05, RF07, RNF02 |
| A quantidade vendida de cada produto em um pedido deve ser maior que zero. | RF07, RNF02 |
| O preço unitário registrado em CONTÉM deve representar o valor praticado no momento da venda. | RF08, RNF02 |
| Todo pedido gera exatamente um CUPOM_FISCAL, e cada cupom pertence a exatamente um pedido. | RF20, RNF02 |
| O CUPOM_FISCAL gera um ou mais registros de pagamento; cada pagamento pertence a um único cupom. | RF09, RF20, RNF02 |
| A divisão da conta pode gerar vários pagamentos vinculados ao mesmo cupom fiscal e, por ele, ao mesmo pedido. | RF09, RF10 |
| Cada pagamento deve registrar o valor correspondente àquela forma de pagamento. | RF10, RNF02 |
| Pagamentos recusados não compõem o valor pago e não tornam o pedido quitado. | RF09, RF17, RNF02 |
| Um pedido só é considerado quitado quando a soma dos pagamentos aprovados de seu cupom corresponde exatamente ao seu `valor_total`. | RF17, RNF02 |
| A recusa de uma tentativa permite nova tentativa no mesmo cupom; os pagamentos anteriormente aprovados continuam válidos. | RF09, RF10, RF17 |
| Cancelamento do pedido e estorno financeiro são eventos distintos, conforme a Seção 4.1.1. | RF18, RNF02 |
| Cada pedido deve possuir uma origem: TOTEM, BALCÃO ou DELIVERY. | RF05, RF06 |
| Quando a origem for TOTEM, o atributo `totem` de PEDIDO deve identificar o equipamento utilizado; nas outras origens, não é preenchido. | RF05, RF06, RNF02 |
| Pedido realizado no balcão deve possuir referência ao funcionário responsável pelo registro. | RF02, RF05, RF06, RNF02 |
| Pedido de DELIVERY não exige funcionário de balcão nem identificação de totem. | RF05, RF06 |
| O cliente pode não possuir cadastro completo no momento do pedido. | RF01, RF05 |
| CPF/CNPJ do cliente é opcional. | RF01 |
| O nome de chamada é registrado em `PEDIDO.nome_comanda`, independentemente de haver cliente associado. Se não for informado, a comanda e a chamada utilizam o número do pedido. | RF05, RF19 |

### 4.1.1 Situação financeira e cancelamento

O valor pago é calculado por `soma(valor_pagamento)` dos registros cujo `status_pagamento` seja **Aprovado**, vinculados ao CUPOM_FISCAL do pedido. Na ausência de pagamentos aprovados, o resultado é zero. Registros **Recusado** ou **Estornado** não entram nessa soma. O valor pago e a situação financeira são informações derivadas em consulta, sem novos atributos armazenados em PEDIDO.

| Condição | Situação do pedido |
|---|---|
| Valor pago igual a zero | Sem valor pago; não quitado. |
| Valor pago maior que zero e menor que `valor_total` | Parcialmente pago; permanece pendente pelo valor restante. |
| Valor pago igual a `valor_total` | Quitado; apto à liberação para preparo. |
| Valor pago maior que `valor_total` | Divergência a conciliar; não deve ser tratada como quitação regular. |
| Pedido cancelado, com pagamentos aprovados ainda não estornados | Cancelado, com devolução financeira pendente; não pode seguir para preparo ou entrega. |
| Pedido cancelado, sem valores aprovados remanescentes | Cancelado, sem valor pendente de devolução. |

O cancelamento tem precedência sobre a liberação do pedido, mesmo que o valor pago corresponda ao total. Uma tentativa recusada não cancela automaticamente o pedido nem desfaz os pagamentos aprovados anteriores. Uma nova tentativa gera outro PAGAMENTO vinculado ao mesmo `id_cupom_fiscal`, preservando o registro recusado.

**Proposta de tratamento de cancelamento, a validar com a unidade:** registrar **CANCELADO** em `status_preparo` e impedir a continuidade do preparo ou da entrega. Se houver pagamentos aprovados, devolver integralmente cada valor aprovado e alterar seu `status_pagamento` para **Estornado** somente após a confirmação efetiva da devolução. Até essa confirmação, o pagamento permanece **Aprovado** e a devolução fica pendente. Um pagamento recusado não exige estorno, pois não compôs o valor pago. Os dados do pedido, de seu cupom e dos pagamentos permanecem no histórico.

### 4.1.2 Documento fiscal e origem do pedido

Todo pedido gera um documento fiscal, representado pela entidade **CUPOM_FISCAL** e denominado nota fiscal do pedido neste trabalho. Cada pedido possui exatamente um cupom, e o cupom gera os registros de PAGAMENTO. O encadeamento adotado é **PEDIDO — GERA — CUPOM_FISCAL — GERA — PAGAMENTO**.

A origem é registrada em `PEDIDO.origem_pedido`, com os valores **TOTEM**, **BALCÃO** ou **DELIVERY**. O atributo `PEDIDO.totem` identifica o equipamento apenas quando a origem for TOTEM; ele é um dado do pedido, sem entidade ou relacionamento próprio para o equipamento.

## 4.2 Restrições Organizacionais

| Restrição | Impacto no modelo |
|---|---|
| Atualmente existe um fornecedor principal, mas outros fornecedores podem ser utilizados quando houver necessidade e autorização. | O modelo permite cadastrar múltiplos fornecedores. |
| O delivery utiliza sua própria plataforma de pedidos. | O pedido é identificado pela origem DELIVERY, sem identificação obrigatória de totem ou funcionário de balcão. |
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

## 5.3 Entidade: PEDIDO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_pedido | Identificador único do pedido | Obrigatório e único (PK) |
| id_cliente | Cliente relacionado ao pedido | Opcional (FK) |
| id_funcionario | Funcionário responsável pelo pedido de balcão | Condicional (FK) |
| totem | Identificação do equipamento utilizado no autoatendimento | Obrigatório quando `origem_pedido` for TOTEM; não preenchido nas demais origens; não é FK |
| nome_comanda | Nome informado para identificação e chamada na comanda | Opcional; quando preenchido, é usado na chamada; quando ausente, utiliza-se `id_pedido`, mesmo sem cliente associado |
| data_hora | Data e horário do registro | Obrigatório |
| origem_pedido | Origem da realização do pedido | Obrigatório: TOTEM, BALCÃO ou DELIVERY |
| valor_total | Valor total do pedido; **atributo derivado** | Derivado pela soma de `quantidade × preco_unitario` dos produtos associados ao pedido; não é informado livremente |
| status_preparo | Situação do pedido durante a preparação e entrega | Obrigatório: RECEBIDO, EM_PREPARO, PRONTO ou ENTREGUE; CANCELADO é o estado proposto para cancelamentos (Seção 4.1.1) |

### Identificação na comanda

O nome usado na comanda pertence ao pedido e é armazenado em `nome_comanda`. Assim, um pedido sem associação a CLIENTE pode registrar apenas o nome de chamada, sem exigir cadastro ou CPF/CNPJ. Quando houver cliente cadastrado, seu nome pode ser copiado para `nome_comanda` no registro do pedido; o valor registrado na comanda preserva a identificação usada naquela compra, mesmo que o cadastro do cliente seja alterado posteriormente.

Se `nome_comanda` estiver vazio, a comanda identifica a compra pelo número `id_pedido`. Não se cria um cliente fictício para viabilizar a chamada.

### Domínio de `status_preparo`

| Valor | Significado |
|---|---|
| RECEBIDO | Pedido registrado, aguardando confirmação da quitação para liberação ao preparo. |
| EM_PREPARO | Pedido liberado e em preparação ou separação dos produtos. |
| PRONTO | Preparo ou separação concluídos; pedido disponível para entrega. |
| ENTREGUE | Pedido entregue ao cliente. |
| CANCELADO | Estado proposto para registrar o cancelamento e impedir a continuidade do atendimento, conforme a Seção 4.1.1. |

## 5.4 Entidade: PRODUTO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_produto | Identificador único do produto | Obrigatório e único (PK) |
| nome | Nome do produto | Obrigatório |
| preco | Preço atual de venda | Obrigatório; maior que zero |

## 5.5 Entidade: CUPOM_FISCAL

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_cupom_fiscal | Identificador único do documento fiscal | Obrigatório e único (PK) |
| id_pedido | Pedido que gera o documento fiscal | Obrigatório e único (FK); cada pedido gera exatamente um cupom |
| numero | Número do documento fiscal | Obrigatório e único no escopo da unidade analisada |
| data_hora_emissao | Data e horário da emissão do documento fiscal | Obrigatório |

## 5.6 Entidade: PAGAMENTO

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_pagamento | Identificador único do pagamento | Obrigatório e único (PK) |
| id_cupom_fiscal | Documento fiscal que gera o registro de pagamento | Obrigatório (FK); o pedido é obtido pelo cupom |
| forma_pagamento | Forma utilizada no pagamento | Obrigatório: PIX, Crédito, Débito ou Dinheiro |
| valor_pagamento | Valor correspondente à tentativa de pagamento | Obrigatório; maior que zero; compõe o valor pago somente quando `status_pagamento` for Aprovado |
| status_pagamento | Situação do pagamento | Obrigatório: Aprovado ou Recusado; Estornado é o estado proposto após devolução integral confirmada de um pagamento aprovado (Seção 4.1.1) |
| data_hora_pagamento | Data e horário do pagamento | Obrigatório |

## 5.7 Entidade: FORNECEDOR

| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_fornecedor | Identificador único do fornecedor | Obrigatório e único (PK) |
| cnpj | CNPJ do fornecedor | Obrigatório |

## 5.8 Atributos do relacionamento CONTÉM

Há um único relacionamento **PEDIDO — CONTÉM — PRODUTO**. Os atributos `quantidade` e `preco_unitario` descrevem a participação de cada produto em um pedido específico.

| Relacionamento | Atributo | Descrição | Regra de negócio associada |
|---|---|---|---|
| PEDIDO — CONTÉM — PRODUTO | quantidade | Quantidade do produto vendida no pedido | Obrigatório; maior que zero |
| PEDIDO — CONTÉM — PRODUTO | preco_unitario | Preço do produto no momento da venda | Obrigatório; preserva o histórico mesmo após alterações no preço do cadastro |

---

# 6. Modelagem Conceitual

## 6.1 Entidades reconhecidas

| Entidade | Justificativa |
|---|---|
| CLIENTE | Representa o cliente cadastrado relacionado aos pedidos quando houver esse vínculo. |
| FUNCIONARIO | Representa os funcionários que registram pedidos realizados no balcão. |
| PEDIDO | Representa a realização de uma compra e registra sua origem e o totem utilizado, quando aplicável. |
| PRODUTO | Representa os alimentos e bebidas comercializados. |
| CUPOM_FISCAL | Representa o documento fiscal gerado por todo pedido e que gera os registros de pagamento. |
| PAGAMENTO | Registra os pagamentos vinculados ao cupom fiscal do pedido, inclusive pagamentos divididos. |
| FORNECEDOR | Preserva o cadastro dos fornecedores; não possui relacionamentos adicionais nesta versão. |

## 6.2 Atributos e classificações

Os atributos das entidades e dos relacionamentos foram definidos a partir dos processos observados e estão detalhados no Dicionário de Dados da Seção 5.

As classificações conceituais consideram a estrutura, o número de valores, a origem e o papel de cada atributo. Um atributo pode pertencer a mais de uma dessas classificações, pois elas descrevem aspectos diferentes.

| Critério | Classificação adotada | Exemplos e aplicação ao modelo |
|---|---|---|
| Estrutura | Simples | `nome`, `cpf_cnpj`, `totem` e `data_hora` são tratados como valores não decompostos neste recorte. Não foram representados atributos compostos com subatributos. |
| Número de valores | Monovalorados | Cada ocorrência de entidade ou relacionamento tem um único valor para cada atributo, como `status_preparo` e a `quantidade` de um produto em um pedido. Não há atributos multivalorados representados. |
| Origem | Armazenados | `nome_comanda`, `totem` e `preco_unitario` da venda são registrados pelo sistema. |
| Origem | Derivado | `PEDIDO.valor_total` resulta da soma de `quantidade × preco_unitario` do relacionamento PEDIDO — PRODUTO. É monovalorado e não é um valor informado livremente. |
| Papel de identificação | Identificadores | `id_cliente`, `id_pedido` e os demais identificadores próprios distinguem as ocorrências de cada entidade. Restrições adicionais de unicidade estão descritas no dicionário. |
| Domínio | Valores enumerados | `origem_pedido`, `status_preparo` e `status_pagamento` possuem conjuntos definidos de valores possíveis. |

Os vários produtos de um pedido e seus vários pagamentos são representados por relacionamentos, e não por atributos multivalorados. Da mesma forma, `quantidade` e `preco_unitario` descrevem cada ocorrência do relacionamento PEDIDO — PRODUTO.

O valor pago e a situação financeira da Seção 4.1.1 também são resultados derivados em consulta; não foram acrescentados como atributos armazenados de PEDIDO. Caso `valor_total` seja materializado na implementação, deve permanecer consistente com sua fórmula de derivação.

Obrigatoriedade, opcionalidade e uso condicional são restrições complementares: por exemplo, `cpf_cnpj` é opcional, `id_funcionario` depende da origem BALCÃO e `nome_comanda` pode ser omitido quando a chamada utiliza o número do pedido.

As indicações de PK e FK no dicionário antecipam o mapeamento para o modelo lógico relacional. Em uma representação conceitual estrita em Chen, as ligações entre entidades são expressas pelos relacionamentos e suas cardinalidades, sem repetir as FKs como atributos conceituais. Assim, os campos marcados como FK neste dicionário servem de referência para a implementação; os identificadores próprios continuam identificando suas respectivas entidades.

## 6.3 Relacionamentos pertinentes

| Relacionamento | Descrição | Cardinalidade |
|---|---|---|
| CLIENTE — REALIZA — PEDIDO | Um cliente pode realizar vários pedidos; o cliente associado é opcional. | 1:N |
| FUNCIONARIO — REGISTRA — PEDIDO | Um funcionário pode registrar vários pedidos de balcão. | 1:N |
| PEDIDO — CONTÉM — PRODUTO | Único relacionamento entre pedido e produto, com quantidade e preço unitário da venda. | N:M |
| PEDIDO — GERA — CUPOM_FISCAL | Todo pedido gera exatamente um cupom, e cada cupom pertence a um pedido. | 1:1 |
| CUPOM_FISCAL — GERA — PAGAMENTO | Um cupom gera um ou mais pagamentos, e cada pagamento pertence a um único cupom. | 1:N |

## 6.4 Restrições aplicadas ao modelo

- A origem do pedido deve ser TOTEM, BALCÃO ou DELIVERY.
- `totem` é um atributo de PEDIDO e identifica o equipamento quando a origem é TOTEM; não existe entidade TOTEM.
- `id_funcionario` é utilizado quando a origem é BALCÃO. Pedidos de DELIVERY não exigem funcionário de balcão nem identificação de totem.
- Todo pedido gera um CUPOM_FISCAL, e os pagamentos são vinculados a esse documento fiscal.
- O cupom pode gerar múltiplos pagamentos para representar divisão da conta.
- Somente pagamentos aprovados compõem o valor pago; a quitação exige igualdade com o total do pedido. Cancelamento e estorno seguem a Seção 4.1.1.
- Há apenas um relacionamento CONTÉM entre PEDIDO e PRODUTO, com `quantidade` e `preco_unitario`. `valor_total` é derivado da soma dos produtos desses dois valores.

---

# 7. Diagrama Entidade-Relacionamento (DER)

## 7.1 DER da We Coffee

![DER da We Coffee com pedido, produto, cupom fiscal e pagamento](<./WECOFFE/Modelo_Conceitual_WeCoffee_BRModelo.png>)

## 7.2 Principais relacionamentos

| Entidade A | Relacionamento | Entidade B | Cardinalidade |
|---|---|---|---|
| CLIENTE | realiza | PEDIDO | 1:N |
| FUNCIONARIO | registra | PEDIDO | 1:N |
| PEDIDO | contém | PRODUTO | N:M |
| PEDIDO | gera | CUPOM_FISCAL | 1:1 |
| CUPOM_FISCAL | gera | PAGAMENTO | 1:N |

### Relacionamento PEDIDO — CONTÉM — PRODUTO

A relação conceitual é de muitos-para-muitos: um pedido contém um ou mais produtos, e um produto pode aparecer em vários pedidos. Há um único relacionamento CONTÉM, com os atributos `quantidade` e `preco_unitario`, preservando o volume vendido e o preço praticado em cada pedido.

Relacionamentos N:M com atributos são válidos no modelo conceitual. No mapeamento lógico relacional, CONTÉM poderá ser implementado por uma tabela associativa; essa implementação não exige outra entidade no DER conceitual.

### Documento fiscal e pagamentos

Todo pedido gera uma nota fiscal, representada por CUPOM_FISCAL. A relação PEDIDO — GERA — CUPOM_FISCAL é 1:1. O cupom, por sua vez, gera um ou mais pagamentos, permitindo divisão da conta sem criar outra ligação direta entre PEDIDO e PAGAMENTO.

Cada PAGAMENTO referencia o cupom do pedido. Tentativas recusadas permanecem no histórico, mas somente pagamentos aprovados compõem o valor pago. A quitação e os efeitos do cancelamento estão definidos na Seção 4.1.1.

---

# 8. Justificativa Técnica

## 8.1 Decisões de abstração e modelagem

| Decisão | Justificativa |
|---|---|
| Escolha das entidades | Foram preservados os cadastros de clientes, funcionários, produtos e fornecedores, além do pedido e do pagamento; CUPOM_FISCAL representa o documento gerado por todo pedido. |
| PEDIDO como entidade central | O pedido conecta o processo de venda ao cliente, ao funcionário responsável, aos produtos e ao documento fiscal. |
| Relacionamento único PEDIDO — CONTÉM — PRODUTO | Representa a relação N:M e registra quantidade e preço histórico como atributos do relacionamento. |
| CUPOM_FISCAL entre PEDIDO e PAGAMENTO | Explicita a regra de que todo pedido gera um documento fiscal e que os pagamentos são vinculados a ele. |
| CUPOM_FISCAL — GERA — PAGAMENTO em 1:N | Permite representar mais de uma forma de pagamento para o mesmo documento fiscal. |
| `valor_pagamento` | Registra quanto foi pago em cada parte quando a conta é dividida. |
| `origem_pedido` | Diferencia TOTEM, BALCÃO e DELIVERY. |
| `totem` como atributo de PEDIDO | Identifica o equipamento utilizado no autoatendimento, sem manter entidade própria. |
| FUNCIONARIO condicional em PEDIDO | Identifica o responsável pelo registro quando a origem é BALCÃO. |
| Quitação calculada a partir de PAGAMENTO | A consulta passa pelo CUPOM_FISCAL; somente valores aprovados compõem o valor pago. |
| FORNECEDOR | Seu cadastro foi preservado, sem acrescentar relacionamentos fora das alterações solicitadas. |

## 8.2 Por que não outras alternativas?

| Alternativa | Motivo da rejeição |
|---|---|
| Usar apenas o preço atual de PRODUTO para consultar vendas anteriores | Não preservaria o preço praticado em cada venda; esse valor é mantido em `preco_unitario` do relacionamento CONTÉM. |
| CUPOM_FISCAL 1:1 PAGAMENTO | Não representaria a possibilidade de dividir a conta entre diferentes formas de pagamento. |
| Criar uma entidade para cada origem do pedido | As origens são representadas por `origem_pedido`, e o equipamento de autoatendimento é registrado em `totem`. |
| Limitar o modelo a apenas um FORNECEDOR | Embora exista um fornecedor principal, a organização pode utilizar outros fornecedores quando necessário. |

## 8.3 Justificativa do DER

O DER representa o pedido, seus produtos, o documento fiscal e os pagamentos. O relacionamento único PEDIDO — CONTÉM — PRODUTO registra as quantidades e o preço praticado na venda. O atributo derivado `valor_total` resulta da soma de `quantidade × preco_unitario` de cada produto associado.

Todo PEDIDO gera exatamente um CUPOM_FISCAL, e esse documento gera um ou mais PAGAMENTOS. A divisão da conta é preservada, e somente valores aprovados compõem a quitação do pedido. Tentativas recusadas e o tratamento proposto de cancelamento e estorno seguem a Seção 4.1.1.

A origem é registrada em `origem_pedido`, com TOTEM, BALCÃO ou DELIVERY. Quando a origem é TOTEM, o atributo `totem` registra o equipamento utilizado. Os cadastros de CLIENTE, FUNCIONARIO e FORNECEDOR são preservados.

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
| **Trechos rejeitados ou corrigidos** | Nem tudo que a IA sugeriu ficou no modelo final. O exemplo mais claro foi a cardinalidade entre PEDIDO e PAGAMENTO: a primeira sugestão veio como 1:1, o que simplesmente não bateria com o que vimos na loja — a divisão de conta é algo real e recorrente. Corrigimos para 1:N. Outro ponto ajustado foi a tentativa inicial de manter a quantidade disponível em mais de um cadastro; percebemos que isso duplicaria a informação e resolvemos manter a quantidade e a data de atualização em PRODUTO. |
| **Justificativa da escolha final** | As decisões finais foram tomadas pelo grupo com base nas informações obtidas na organização e na necessidade de manter coerência entre o modelo e os processos observados. |
| **Reflexão crítica** | De modo geral, a IA ajudou a organizar as ideias e a apontar inconsistências que a gente não tinha notado, mas todas as decisões finais passaram pela validação do grupo com base no que foi observado e coletado na visita e na entrevista — a IA sugeriu, mas quem decidiu foi o grupo mesmo. |

---
- **Participação (10%):** envolvimento nas discussões técnicas e nas decisões do grupo.
- **Comprometimento (8%):** cumprimento de prazos e responsabilidades assumidas.
- **Colaboração (4%):** respeito às contribuições dos colegas, cooperação na construção do projeto e colaboração equilibrada no histórico de commits do repositório GitHub.
- **Autonomia (7%):** busca independente de soluções e proposta de melhorias.

----

# Conclusão

O modelo conceitual desenvolvido representa atendimento, pedidos, produtos, documentos fiscais, pagamentos, preparação e entrega, preservando os cadastros de clientes, funcionários e fornecedores.

A modelagem foi estruturada para manter consistência entre os processos levantados, os requisitos, as regras de negócio, o dicionário de dados e o DER.

---

## Alterações

### Revisão da estrutura — 26/10/2026

- Incluído CUPOM_FISCAL: todo PEDIDO gera um documento fiscal, e esse cupom gera os PAGAMENTOS.
- Mantido um único relacionamento PEDIDO — CONTÉM — PRODUTO, com quantidade e preço unitário.
- O equipamento de autoatendimento passou a ser o atributo `totem` de PEDIDO; `origem_pedido` registra TOTEM, BALCÃO ou DELIVERY.
- Retirados do modelo o recebimento de produtos, os atributos e as regras de controle de saldo. Foram preservados os demais cadastros e as regras de pagamento, com as referências atualizadas para CUPOM_FISCAL.
- Confirmada a ausência de atributo de subtotal. `valor_total` permanece derivado.
- Atualizados README, dicionário HTML, DER em PDF/PNG/JPG e fluxograma: 7 entidades, 5 relacionamentos e 32 atributos documentados (30 das entidades e 2 do relacionamento CONTÉM).

### Histórico de versões anteriores

Os registros abaixo descrevem versões anteriores; as entidades e regras vigentes estão nas Seções 3 a 8.

**26/10/2026**

- Numerados os requisitos funcionais de RF01 a RF16 e os não funcionais de RNF01 a RNF06, com referências nas regras operacionais.
- Acrescentados RF17 e RF18 para situação financeira, cancelamento, estorno e recomposição; detalhada a atualização do estoque em RF11.
- Documentadas a exclusão dos pagamentos recusados do valor pago e a quitação pela soma exata dos pagamentos aprovados. Incluídas propostas a validar para cancelamento, estorno financeiro, momento da baixa e retorno de produtos ao estoque, com atualização do dicionário em index.html.
- Corrigidas as associações de clientes, funcionários e totens para utilizar os identificadores e relacionamentos existentes, sem referências à entidade UNIDADE ou ao CPF de funcionário.
- Corrigidos os atributos de FORNECEDOR para `id_fornecedor` (identificador) e `cnpj` (CNPJ), mantendo a referência por `id_fornecedor` em ENTRADA_ESTOQUE e alinhando o requisito RF13 e o dicionário em index.html.
- Corrigido o caminho da imagem do fluxograma para uma referência relativa ao repositório.
- Esclarecida a validade dos relacionamentos N:M com atributos no modelo conceitual e a distinção em relação ao mapeamento para tabelas associativas no modelo lógico, preservando as oito entidades existentes.
- Explicitada a classificação de `valor_total` como atributo derivado e complementadas as classificações conceituais da Seção 6.2, com distinção entre relacionamentos conceituais e referências de FK para implementação.
- Detalhados os domínios de `status_preparo` e `TOTEM.status`. Acrescentados RF19 e `PEDIDO.nome_comanda` para identificação sem cadastro de cliente, com uso do número do pedido quando o nome não for informado. O dicionário passa a documentar 38 atributos: 35 das entidades e 3 dos relacionamentos.

**23/10/2026**

- Removidas as entidades ITEM_PEDIDO, ITEM_ENTRADA e ESTOQUE, incluindo suas seções no dicionário de dados e seus relacionamentos anteriores.
- Preservados os requisitos funcionais e as regras de negócio de vendas, pagamentos, quantidades, preço histórico, disponibilidade e recebimento de produtos.
- Representados diretamente os relacionamentos N:M entre PEDIDO e PRODUTO e entre ENTRADA_ESTOQUE e PRODUTO. Quantidade vendida e preço unitário da venda passaram a ser atributos do primeiro relacionamento; quantidade recebida passou a ser atributo do segundo.
- Transferido o controle de estoque para PRODUTO, com os atributos quantidade_disponivel e data_atualizacao. As vendas reduzem a quantidade disponível e os recebimentos a aumentam, mantendo a regra de saldo não negativo.
- Mantido o cálculo de valor_total do pedido pela soma de quantidade × preco_unitario dos produtos associados.
- Revisados os requisitos, as descrições, as justificativas técnicas, as cardinalidades e a numeração das seções para refletir a estrutura atual.
- Atualizado o dicionário em index.html, incluindo a busca e as contagens do modelo: 8 entidades, 7 relacionamentos e 37 atributos documentados, sendo 34 das entidades e 3 dos relacionamentos.
- Atualizados os diagramas em PNG, JPG e PDF.
