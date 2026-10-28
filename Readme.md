# We Coffee — Modelo Conceitual de Banco de Dados

# Integrantes

| Nome | RGM |  Usuário GITHUB |
|----|----|----|
| Guilherme Souza Lima | 46899502 | Guilherme-DEV-ALT |
| João Victor Moidano do Valle | 46576461 | JoãoVictorValle |
| Gabriel Amorim Sartori | 46832939 | gabrielamorimsartori28-collab |
| Guilherme Cau Guateli | 46736069 | CacauG |
| Matheus Fernandes Andrade | 46754539 | 01Theuz |

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

Conforme atualização confirmada pelo grupo em **28/10/2026**, a composição informada é de **8 funcionários da cafeteria, 4 profissionais de limpeza terceirizada e 3 seguranças terceirizados**, totalizando **15 pessoas**. Essa informação substitui a estimativa anterior de aproximadamente seis funcionários da cafeteria.

As quantidades de cada grupo foram confirmadas nesta conversa. A distribuição dos dias de trabalho e das folgas apresentada na Seção 2.10 continua sendo **fictícia**, sem representar a escala real da unidade ou das prestadoras.

A unidade trabalha com diferentes formas de atendimento:

- **Totem de autoatendimento:** o próprio cliente realiza o pedido e o pagamento.
- **Balcão:** o funcionário registra o pedido e informa o nome do cliente. As vendas utilizam um registro que permanece aberto para o atendimento, sem solicitar `id_funcionario` a cada venda; o vínculo do pedido com um funcionário cadastrado é opcional.
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

## 2.1 Cadastro de clientes, funcionários e produtos

O sistema proposto mantém os seguintes cadastros:

- **CLIENTE:** identificado por `id_cliente`, com `nome` obrigatório e `cpf_cnpj` opcional. Quando informado, o documento deve ser único.
- **FUNCIONARIO:** identificado por `id_funcionario`, com `nome` e `cargo` obrigatórios. O cadastro permite associar funcionários aos pedidos de balcão que registrarem, sem tornar o vínculo obrigatório para realizar a venda.
- **PRODUTO:** identificado por `id_produto`, com `nome` e `preco` de venda atual obrigatórios. O preço deve ser maior que zero.

O grupo informou a retirada de compras e do cadastro de FORNECEDOR do recorte, em razão de um fornecimento único inteiramente vinculado à empresa. Em atualização de 28/10/2026, confirmou abastecimento diário. A justificativa do recorte, os limites de acesso às informações e as propostas de controle estão na Seção 2.9.

## 2.2 Atendimento e registro do pedido

O pedido pode ser realizado por totem, balcão ou delivery. Cada PEDIDO possui `id_pedido`, `data_hora`, `origem_pedido` e `status_preparo`.

Os dados complementares dependem do atendimento:

- Quando a origem for **TOTEM**, o atributo `totem` identifica o equipamento utilizado.
- Quando a origem for **BALCÃO**, as vendas utilizam um registro que permanece aberto para o atendimento, sem solicitar `id_funcionario` a cada venda. A associação do pedido a um funcionário cadastrado é opcional.
- Quando a origem for **DELIVERY**, não são obrigatórios o funcionário de balcão nem a identificação de totem.
- O vínculo com um cliente cadastrado, representado por `id_cliente`, é opcional.
- O nome utilizado para identificação e chamada é registrado em `nome_comanda`, mesmo quando não existe cliente associado. Quando esse nome não for informado, utiliza-se `id_pedido`.

## 2.3 Associação dos produtos e cálculo do pedido

Cada pedido deve conter pelo menos um produto cadastrado, identificado por `id_produto`.

No relacionamento **PEDIDO — CONTÉM — PRODUTO**, são registrados:

- `quantidade`: número inteiro de unidades daquele produto no pedido, obrigatoriamente maior que zero;
- `preco_unitario`: preço praticado para aquele produto naquela venda, preservado mesmo quando o preço atual do cadastro for alterado.

O atributo `valor_total` de PEDIDO é derivado pela fórmula:

`valor_total = soma(quantidade × preco_unitario)`

O cálculo considera todos os produtos associados ao pedido. O total não é informado livremente e não exige um atributo de subtotal.

## 2.4 Emissão do documento fiscal

Todo pedido gera exatamente um documento fiscal, representado por CUPOM_FISCAL e denominado nota fiscal do pedido neste trabalho.

O documento possui:

- `id_cupom_fiscal`: identificador único do cupom;
- `id_pedido`: referência obrigatória e única ao pedido que gerou o documento;
- `numero`: número obrigatório e único no escopo da unidade;
- `data_hora_emissao`: data e horário obrigatórios da emissão.

Cada cupom pertence a um único pedido e reúne os registros de pagamento dessa compra.

## 2.5 Registro das tentativas e divisão do pagamento

Cada tentativa é registrada em PAGAMENTO com:

- `id_pagamento`;
- `id_cupom_fiscal`;
- `forma_pagamento`;
- `valor_pagamento`;
- `status_pagamento`;
- `data_hora_pagamento`.

As formas previstas são **PIX, Crédito, Débito e Dinheiro**. O valor de cada tentativa deve ser maior que zero.

Um cupom pode possuir vários registros, permitindo dividir a conta entre diferentes formas de pagamento ou realizar uma nova tentativa após uma recusa.

Somente registros com `status_pagamento = Aprovado` compõem o valor pago. Registros **Recusado** ou **Estornado** permanecem no histórico e são excluídos dessa soma.

## 2.6 Preparação e entrega

O acompanhamento utiliza `PEDIDO.status_preparo`, com os estados:

| Estado | Significado |
|---|---|
| RECEBIDO | Pedido registrado, aguardando confirmação da quitação para liberação ao preparo. |
| EM_PREPARO | Pedido liberado e em preparação ou separação dos produtos. |
| PRONTO | Preparação ou separação concluída; pedido disponível para entrega. |
| ENTREGUE | Pedido entregue ao cliente. |

A liberação para preparo depende da igualdade entre o `valor_total` e a soma dos pagamentos aprovados do cupom.

A identificação para entrega utiliza `nome_comanda` ou, quando ausente, `id_pedido`.

## 2.7 Cancelamento e estorno — proposta a validar

O cancelamento é representado pelo estado **CANCELADO** em `PEDIDO.status_preparo`, impedindo a continuidade do preparo ou da entrega.

Quando houver pagamentos aprovados, cada devolução financeira deve corresponder integralmente ao respectivo `valor_pagamento`. O `status_pagamento` passa para **Estornado** somente após a confirmação efetiva da devolução.

Até essa confirmação, o pagamento permanece **Aprovado**, indicando valor pendente de devolução. Pagamentos recusados não exigem estorno.

O pedido, seu cupom e seus pagamentos permanecem no histórico. Os estágios em que o cancelamento pode ser autorizado ainda precisam ser confirmados com a unidade.

## 2.8 Consulta e análise de vendas

As consultas relacionam:

- **PEDIDO:** `id_pedido`, `data_hora`, `origem_pedido`, `nome_comanda`, `status_preparo` e `valor_total`;
- **PRODUTO e CONTÉM:** identificação e nome do produto, `quantidade` e `preco_unitario`;
- **CUPOM_FISCAL:** identificação do documento, `numero` e `data_hora_emissao`;
- **PAGAMENTO:** identificação da tentativa, `forma_pagamento`, `valor_pagamento`, `status_pagamento` e `data_hora_pagamento`.

Esses dados permitem consultar compras, documentos emitidos, pagamentos divididos, recusas, valores aprovados e situações financeiras.

Na consolidação mensal, um pedido com vários produtos ou pagamentos não deve ter seu total contado repetidamente. A data de referência do fechamento e o tratamento de estornos posteriores devem ser definidos com a unidade.

## 2.9 Conferência dos processos típicos e justificativas do recorte

A pesquisa sobre cafeterias foi utilizada para ampliar as perguntas do levantamento. O estudo do [Sebrae sobre o perfil das cafeterias brasileiras](https://agenciasebrae.com.br/dados/muito-alem-do-cafezinho-com-pao-de-queijo-conheca-o-perfil-das-cafeterias-brasileiras/) aborda preparo, qualificação da equipe, padrões de qualidade, fornecedores e relacionamento com clientes. Essas referências setoriais não comprovam como a We Coffee analisada realiza cada atividade. A matriz abaixo combina o relato já documentado, as informações complementares do grupo e os processos prováveis sugeridos pela pesquisa e pela IA.

| Processo | Situação na organização e dados envolvidos | Tratamento no trabalho e confirmação necessária |
|---|---|---|
| Cadastros de clientes, funcionários e produtos | Já descritos: identificadores, nomes, documento opcional do cliente, cargo e preço atual do produto. | Incluídos no modelo e detalhados nas Seções 2.1, 3 e 5. |
| Atendimento, pedido e venda | Já descritos: origem, equipamento quando aplicável, nome de comanda, produtos, quantidades e preços praticados. | Incluídos, independentemente de sua relação direta com o problema de fechamento mensal. |
| Documento fiscal e pagamentos | Já descritos: número e data de emissão, forma, valor, situação e data de cada tentativa de pagamento. | Incluídos. Confirmar com a unidade os procedimentos fiscais diante de cancelamento. |
| Preparação, separação e entrega | Já descritos: identificação do pedido e estados de preparo. | Incluídos. Receitas, ingredientes, produção de alimentos e procedimentos de qualidade ainda não foram detalhados. |
| Cancelamento e devolução financeira | Tratamento proposto com pedido CANCELADO e pagamento Estornado após confirmação. | Incluído como proposta a validar, sem apresentá-lo como procedimento já confirmado na visita. |
| Fechamento de vendas | Dificuldade de consolidação mensal registrada no levantamento; envolve pedidos, produtos, documentos e pagamentos. | Incluído. Abertura e fechamento de caixa, despesas e conciliação ainda precisam ser detalhados; contas a pagar possui limitação de acesso específica, registrada abaixo. |
| Contas a pagar | O grupo não conseguiu acesso às informações desse processo. Valores, vencimentos, credores, responsáveis e situação dos pagamentos não foram disponibilizados. | Processo registrado como informação não acessível ao grupo, sem dados financeiros ou funcionalidade modelados. A falta de acesso não comprova inexistência nem permite afirmar como a atividade é executada. |
| Compras e cadastro de fornecedor | O grupo informou um único fornecimento totalmente vinculado à empresa e solicitou retirar compras e FORNECEDOR do recorte. | Retirados como funcionalidade e cadastro próprios desta versão. Ainda é necessário confirmar quem solicita, compra e autoriza o fornecimento, inclusive se a gestão é centralizada. O abastecimento diário está confirmado, independentemente da existência de um cadastro local de fornecedor. |
| Abastecimento e recebimento | O grupo confirmou em 28/10/2026 que o abastecimento ocorre todos os dias. Horários, produtos, quantidades recebidas, responsáveis e forma de conferência não foram detalhados. | Frequência incluída no mapeamento como informação do grupo. Não se presume que todos os produtos sejam repostos todos os dias, que não existam sobras ou que o recebimento já esteja representado no banco. |
| Disponibilidade e estoque | O relato anterior informa conferência e atualização da disponibilidade quando um produto acaba. O funcionamento do controle quantitativo não foi confirmado. | A Seção 2.9.2 registra o estoque como lacuna em aberto. Sua discussão foi adiada pelo grupo; não há solução aprovada nem representação nas seis entidades do modelo atual. |
| Escala e organização da equipe | Nenhuma escala real foi localizada nos arquivos do projeto. O grupo solicitou um registro manual com pessoa, setor, vínculo, período e dias de trabalho/folga. | Funcionalidade de registro e consulta incluída em RF25, acompanhada de exemplo com 15 nomes e códigos fictícios na Seção 2.10. Datas, horários e distribuição real da equipe continuam pendentes de levantamento. |
| Limpeza e conservação | O grupo informou serviço terceirizado com quatro pessoas. Ambientes atendidos, tarefas, frequência e responsável pela prestação ainda precisam ser detalhados. | Processo incluído no mapeamento. O quadro fictício demonstra apenas a distribuição dos dias; não representa contrato, checklist ou escala real da prestadora. |
| Segurança | O grupo informou serviço terceirizado com três pessoas. Postos, horários, responsáveis e registros de ocorrências ainda não foram informados. | Processo incluído no mapeamento. Contratos e gestão de pessoal da prestadora não foram modelados; confirmar quais dados a unidade precisa acompanhar. |
| Validade dos produtos | Segundo o grupo, não há controle específico de validade no recorte levantado, tendo sido apresentada como justificativa a reposição diária. Não foram obtidos detalhes sobre conferência de prazos, rótulos ou tratamento das sobras. | Justificativa documentada como relato, sem concluir que a reposição diária dispensa a conferência de validade. Confirmar quem realiza essa verificação e onde ela é registrada, conforme a Seção 2.9.1. |
| Perdas e desperdício | O grupo não teve acesso às informações desse processo. Quantidades, motivos, datas e destinação das perdas não foram disponibilizados. | Registrado como limitação de acesso, sem afirmar perda zero ou inexistência de desperdício. O eventual tratamento das perdas no controle de estoque também permanece em aberto. |
| Produção e controle de qualidade | Produtos preparados na unidade, ingredientes utilizados e procedimentos de qualidade ainda não foram detalhados. | Processo ainda a conferir. A reposição diária não permite inferir como ocorre a produção nem substituir o levantamento de qualidade e conservação. |
| Campanhas e parcerias | O grupo informou campanhas quase todos os meses, em função de parcerias com grandes empresas. Como exemplo, funcionários do banco CITI que gastam acima de R$ 39,00 recebem uma bebida na próxima visita, apresentando o cupom fiscal da compra. | Registro informativo incluído em RF24, conforme relato do grupo. O benefício é uma cortesia posterior; sua concessão e seu resgate não serão controlados pelo sistema nesta etapa. Condições ainda desconhecidas permanecem na Seção 2.9.3. |
| Programas do aplicativo | Não foram confirmados programa de pontos, cashback, cupons próprios do aplicativo ou regras de fidelidade digital. | Permanecem pendentes de levantamento. A campanha do CITI não foi atribuída ao aplicativo, e a existência do canal DELIVERY não comprova um programa de fidelidade. |
| Divulgação e eventos | A pesquisa setorial indica relacionamento e comunicação com clientes, mas não foram detalhados os canais de divulgação das campanhas nem a existência de eventos nesta unidade. | Não incluídos como funcionalidades ou entidades enquanto não houver confirmação. Registrar se são executados pela unidade, pela empresa ou por terceiros. |

**Limite de cobertura:** ter um fornecedor único ou terceirizar um serviço não elimina a necessidade de mapear a atividade. As atualizações acima foram fornecidas pelo grupo em 28/10/2026, nesta conversa; não representam uma nova visita nem acesso a registros internos. Contas a pagar e perdas permanecem documentados como informações não acessíveis, e não como processos inexistentes. Os processos confirmados ainda sem representação no modelo exigem posterior detalhamento dos requisitos, do dicionário e do DER.

### 2.9.1 Limites do levantamento e validade

O grupo informou que não conseguiu acesso aos dados de contas a pagar nem aos registros de perdas. Por esse motivo, o trabalho não descreve valores, documentos, responsáveis ou procedimentos desses processos. Essa limitação deve permanecer explícita na avaliação da cobertura do levantamento.

Sobre validade, o relato recebido foi de ausência de controle específico, justificada pela reposição diária. O abastecimento diário foi confirmado, mas não foram confirmados prazo de uso, data de preparo, identificação dos produtos ou destino das sobras. Assim, não se afirma que os produtos não tenham validade nem que todos sejam consumidos ou descartados no mesmo dia.

Como referência para a próxima conferência, a [cartilha de Boas Práticas para Serviços de Alimentação da Anvisa](https://www.gov.br/anvisa/pt-br/centraisdeconteudo/publicacoes/alimentos/manuais-guias-e-orientacoes/cartilha-boas-praticas-para-servicos-de-alimentacao.pdf) orienta verificar as condições e os prazos dos alimentos recebidos e identificar alimentos preparados armazenados com nome, data de preparo e validade. Portanto, a reposição diária não deve ser apresentada no trabalho como dispensa desses cuidados. A referência não comprova como a unidade executa a verificação; isso ainda precisa ser levantado.

### 2.9.2 Estoque — lacuna em aberto

O abastecimento diário e a atualização da disponibilidade quando um produto acaba foram relatados pelo grupo. Ainda não foi confirmado como a unidade registra e acompanha quantitativamente o estoque.

Por decisão do grupo, a definição da solução de estoque foi adiada. Permanecem em aberto os dados necessários, os responsáveis, as unidades de medida, o momento da baixa, eventuais reservas, o tratamento de cancelamentos, retornos, cortesias, perdas e a conferência dos saldos.

Nenhuma proposta de controle de estoque foi adotada nesta versão. O tema será retomado posteriormente, antes de definir entidades, atributos, requisitos e regras ou alterar o dicionário e o DER. As seis entidades e as contagens atuais permanecem inalteradas.

### 2.9.3 Campanhas de parceria e benefício do banco CITI

Segundo informação do grupo em 28/10/2026, a unidade realiza campanhas quase todos os meses, conforme as parcerias fechadas com grandes empresas. Isso não estabelece uma periodicidade mensal obrigatória nem confirma as condições de todas as campanhas.

O exemplo relatado é o seguinte:

- **Público:** funcionários do banco CITI.
- **Condição de compra:** gasto acima de R$ 39,00. O relato indica valor estritamente maior que R$ 39,00; não foi informado que uma compra de exatamente R$ 39,00 seja elegível.
- **Benefício:** uma bebida na próxima visita à loja.
- **Comprovante:** apresentação do cupom fiscal da compra que gerou o benefício.

Ainda precisam ser confirmados a vigência da campanha, a forma de comprovar vínculo com o CITI, quais bebidas participam, o prazo de resgate, o critério do valor elegível, os canais de compra aceitos, a possibilidade de acumular benefícios e a forma de impedir reutilização do mesmo cupom. Não se presume um limite de usos ou um mecanismo de validação já existente.

Por decisão do grupo, a campanha será tratada apenas como **registro informativo**, conforme RF24: identificação da campanha, empresa parceira, público-alvo, condição de compra, benefício, comprovante exigido e observações sobre condições ainda pendentes. A vigência será indicada como pendente enquanto não for informada. Não serão registrados eventos individuais de concessão ou resgate nem realizada validação automática de elegibilidade nesta etapa. As regras de pedidos, preços e pagamentos permanecem inalteradas.

O registro informativo integra os requisitos por solicitação do grupo, mas ainda depende de representação no dicionário e no DER; não se apresenta como funcionalidade já implementada. Nenhum programa próprio do aplicativo foi confirmado, e a campanha não foi vinculada a esse canal sem informação da unidade.

## 2.10 Registro de escala — exemplo fictício 6x1

O grupo solicitou incluir a funcionalidade de **registro manual e consulta de escala**, conforme RF25. Não foi encontrada uma escala real no material do projeto; para demonstrar os dados desse registro, foi criada a seguinte **semana-modelo com nomes, códigos e distribuição de trabalho e folgas fictícios**, de segunda a domingo, sem data real de vigência. As quantidades utilizadas correspondem à composição confirmada pelo grupo: oito pessoas da cafeteria, quatro da limpeza e três da segurança, totalizando 15 pessoas. Os nomes não identificam funcionários reais da unidade ou das prestadoras.

### Dados usados no exemplo

- **Pessoa:** código e nome fictícios, sem documento ou identificador real. Os códigos C01 a C08, L01 a L04 e S01 a S03 não são valores já cadastrados em `id_funcionario`; o exemplo não cria vínculos com pedidos ou cadastros reais.
- **Setor e vínculo:** equipe da cafeteria, limpeza terceirizada e segurança terceirizada, conforme a composição informada pelo grupo.
- **Período:** semana-modelo, sem datas reais.
- **Dia e situação:** segunda a domingo, com T para trabalho previsto e F para folga prevista. São seis marcações T e uma F por pessoa; não se registram presença efetiva, faltas ou horas trabalhadas.

| Código fictício | Nome fictício | Setor | Vínculo no exemplo | Seg | Ter | Qua | Qui | Sex | Sáb | Dom |
|---|---|---|---|---|---|---|---|---|---|---|
| C01 | Ana Martins | Cafeteria | Equipe da cafeteria | F | T | T | T | T | T | T |
| C02 | Bruno Almeida | Cafeteria | Equipe da cafeteria | T | F | T | T | T | T | T |
| C03 | Camila Rocha | Cafeteria | Equipe da cafeteria | T | T | F | T | T | T | T |
| C04 | Diego Santos | Cafeteria | Equipe da cafeteria | T | T | T | F | T | T | T |
| C05 | Elisa Costa | Cafeteria | Equipe da cafeteria | F | T | T | T | T | T | T |
| C06 | Felipe Ribeiro | Cafeteria | Equipe da cafeteria | T | F | T | T | T | T | T |
| C07 | Helena Duarte | Cafeteria | Equipe da cafeteria | T | T | T | T | F | T | T |
| C08 | Lucas Mendes | Cafeteria | Equipe da cafeteria | T | T | T | T | T | T | F |
| L01 | Marta Oliveira | Limpeza | Terceirizado | F | T | T | T | T | T | T |
| L02 | Paulo Ferreira | Limpeza | Terceirizado | T | F | T | T | T | T | T |
| L03 | Renata Alves | Limpeza | Terceirizado | T | T | F | T | T | T | T |
| L04 | Sérgio Batista | Limpeza | Terceirizado | T | T | T | F | T | T | T |
| S01 | André Carvalho | Segurança | Terceirizado | F | T | T | T | T | T | T |
| S02 | Roberto Nunes | Segurança | Terceirizado | T | T | F | T | T | T | T |
| S03 | Tiago Lopes | Segurança | Terceirizado | T | T | T | F | T | T | T |

### Pessoas com trabalho previsto por dia

| Setor | Seg | Ter | Qua | Qui | Sex | Sáb | Dom |
|---|---|---|---|---|---|---|---|
| Cafeteria | 6 | 6 | 7 | 7 | 7 | 8 | 7 |
| Limpeza | 3 | 3 | 3 | 3 | 4 | 4 | 4 |
| Segurança | 2 | 3 | 2 | 2 | 3 | 3 | 3 |
| **Total** | **11** | **12** | **12** | **12** | **14** | **15** | **14** |

Das 15 folgas do exemplo, 14 ficam entre segunda e sexta e uma no domingo, concentrando a disponibilidade no fim de semana. Os totais representam pessoas com trabalho previsto no dia, não cobertura simultânea ou de todos os turnos.

Horários, intervalos, duração das jornadas, funções por turno, necessidades mínimas de cada posto e revezamento nas semanas seguintes não foram definidos. A distribuição 6x1 dos terceirizados também é uma hipótese didática; a escala real depende de confirmação com a prestadora. O exemplo não comprova a prática da unidade nem a adequação de uma escala operacional.

**Relação com o banco de dados:** RF25 formaliza a funcionalidade de registro e consulta manual solicitada pelo grupo. `FUNCIONARIO` atualmente possui apenas `id_funcionario`, `nome` e `cargo`; o DER e o dicionário ainda não representam o registro da escala com período, setor, vínculo e dias de trabalho/folga. Essa representação continua pendente de modelagem, inclusive para os terceirizados. Os nomes e a distribuição fictícios servem para demonstrar o registro, sem comprovar a escala praticada pela organização.

## 2.11 Próxima conferência com a organização

1. Registrar a composição já confirmada pelo grupo — oito pessoas da cafeteria, quatro da limpeza terceirizada e três da segurança terceirizada — no material do levantamento, identificando a fonte e a data da atualização.
2. Manter os nomes e a escala fictícios como exemplo do registro de RF25. Para uso com dados reais, obter período, horários, folgas, funções, responsáveis e forma de aprovação junto à unidade ou às prestadoras.
3. Detalhar o abastecimento já confirmado como diário: quem solicita, autoriza, compra, recebe e confere, quais produtos e quantidades chegam e como a conferência é registrada, sem presumir gestão centralizada.
4. Retomar posteriormente a lacuna de estoque da Seção 2.9.2, levantando quantidades, responsáveis, momento da baixa, reservas, cortesias, retornos e conferência física antes de definir uma solução. Confirmar o tratamento da validade e das sobras. Contas a pagar e perdas permanecem como informações não acessíveis; novos dados só serão acrescentados se disponibilizados pela organização.
5. Detalhar limpeza e segurança: empresa responsável, atividades, postos, frequência, horários e informações acompanhadas pela unidade.
6. Complementar o registro informativo da campanha CITI e de outras parcerias quando forem fornecidos vigência, bebidas elegíveis e demais condições; manter o desconhecido como pendente, sem ampliar RF24 para concessão ou resgate. Verificar separadamente se existem programas do aplicativo.
7. Conferir produção, qualidade, despesas, fechamento de caixa, divulgação e eventos; justificar com a resposta real cada exclusão.
8. Atualizar requisitos, dicionário e DER após validar os dados e a ampliação do modelo. O registro da pesquisa e da geração da escala está na Seção 9.1; a complementação dos processos e o registro das lacunas estão na Seção 9.2.

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

| Código | Requisito detalhado |
|---|---|
| RF01 | O sistema deve permitir cadastrar clientes, mantendo `id_cliente` como identificador único, registrando `nome` obrigatório e `cpf_cnpj` opcional, único quando informado. |
| RF02 | O sistema deve permitir cadastrar funcionários com `id_funcionario` único, `nome` e `cargo` obrigatórios, permitindo associá-los aos pedidos de balcão que registrarem. |
| RF04 | O sistema deve permitir cadastrar produtos com `id_produto` único e alterar o `nome` e o `preco` atual de um produto identificado por `id_produto`, mantendo nome obrigatório e preço obrigatório e maior que zero. A alteração deve preservar o identificador e os valores históricos de `CONTÉM.preco_unitario`, conforme RF08 e RN12. |
| RF05 | O sistema deve permitir registrar pedidos com `id_pedido`, `data_hora`, `origem_pedido` e `status_preparo`, além de `id_cliente` e `id_funcionario` opcionais, `totem` condicional à origem TOTEM e `nome_comanda` opcional. O `valor_total` deve ser derivado dos produtos associados. |
| RF06 | O sistema deve registrar em `origem_pedido` os valores TOTEM, BALCÃO ou DELIVERY. Quando a origem for TOTEM, deve registrar o equipamento em `totem`. Nas vendas de BALCÃO, não deve exigir o preenchimento de `id_funcionario` para registrar o pedido. |
| RF07 | O sistema deve permitir associar ao pedido um ou mais produtos cadastrados, identificados por `id_produto`, registrando em CONTÉM a `quantidade` inteira e maior que zero de cada produto. |
| RF08 | O sistema deve registrar em CONTÉM o `preco_unitario` praticado para cada produto na venda, preservando esse valor quando `PRODUTO.preco` for alterado posteriormente. |
| RF09 | O sistema deve registrar cada tentativa de pagamento com `id_pagamento`, `id_cupom_fiscal`, `forma_pagamento`, `valor_pagamento`, `status_pagamento` e `data_hora_pagamento`, mantendo os registros aprovados e recusados no histórico. |
| RF10 | O sistema deve permitir dividir a conta em vários pagamentos vinculados ao mesmo `id_cupom_fiscal`, registrando separadamente a `forma_pagamento` e o `valor_pagamento` de cada tentativa. |
| RF15 | O sistema deve permitir consultar o pedido por `id_pedido`, apresentando seus dados de atendimento, produtos com `quantidade` e `preco_unitario`, documento fiscal com `numero` e `data_hora_emissao` e pagamentos com forma, valor, situação e data de processamento. |
| RF16 | O sistema deve permitir consolidar vendas por período, relacionando `data_hora`, `origem_pedido`, `valor_total`, produtos vendidos e os valores e situações dos pagamentos, sem duplicar o total de pedidos que possuam vários produtos ou pagamentos. |
| RF17 | O sistema deve calcular o valor pago pela soma de `valor_pagamento` dos registros Aprovados vinculados ao cupom do pedido e compará-lo com `valor_total`, identificando ausência de pagamento, pagamento parcial, quitação ou divergência. |
| RF18 | Como proposta a validar, o sistema deve registrar o cancelamento em `PEDIDO.status_preparo` e o estorno confirmado em `PAGAMENTO.status_pagamento`, preservando os identificadores, vínculos e dados históricos do pedido, do cupom e das tentativas. |
| RF19 | O sistema deve permitir registrar `nome_comanda` independentemente da existência de `id_cliente`. Quando o nome não for informado, a identificação e a chamada devem utilizar `id_pedido`. |
| RF20 | O sistema deve gerar exatamente um CUPOM_FISCAL para cada pedido, registrando `id_cupom_fiscal`, `id_pedido`, `numero` e `data_hora_emissao`, com identificação e numeração únicas conforme o dicionário. |
| RF21 | O sistema deve permitir localizar um pedido por `id_pedido` e atualizar `status_preparo` para EM_PREPARO, PRONTO ou ENTREGUE conforme o andamento do atendimento descrito na Seção 2.6 e na RN22. A passagem de RECEBIDO para EM_PREPARO exige a quitação calculada por RF17; pedidos cancelados não podem prosseguir para preparo ou entrega. O cancelamento continua sujeito à proposta de RF18, sem ser tratado como atualização comum do preparo. |
| RF22 | **Proposta a validar — auditoria:** o sistema deve registrar os eventos previstos na Seção 5 do dicionário HTML, incluindo consultas, exportações, inclusões e alterações de cadastros, pedidos e pagamentos, mudanças de preço, cancelamentos, estornos, autenticação, mudanças de permissões e tentativas sem autorização. Cada evento deve conter `id_log` único, `data_hora_evento`, `operacao`, `entidade_alvo` quando aplicável, `referencia_registro` quando houver registro específico, `resultado` (SUCESSO, NEGADO ou FALHA), `identificacao_ator` e `perfil_utilizado` quando disponíveis e `motivo` quando aplicável. O resultado da operação não substitui `PAGAMENTO.status_pagamento`. |
| RF23 | **Proposta a validar — controle de acesso:** antes de executar uma operação, o sistema deve verificar o perfil da conta, serviço ou sessão, a operação solicitada e o recurso ou registro envolvido, autorizando ou negando a ação conforme a matriz proposta na Seção 6.2 do dicionário HTML. A verificação deve abranger consultas, cadastros, alterações, cancelamentos, estornos, exportações e acesso aos logs. Operações sem autorização expressa devem ser negadas; tentativas negadas devem ser registradas conforme RF22. Os perfis Atendimento, Gerência e Consulta gerencial, assim como os acessos técnicos de TOTEM e DELIVERY, dependem de confirmação com a unidade. |
| RF24 | O sistema deve permitir registrar e consultar informações de campanhas de parceria com identificação da campanha, empresa parceira, público-alvo, condição de compra, benefício, comprovante exigido, vigência quando conhecida e observações sobre condições pendentes. Para a campanha CITI, o registro deve preservar as informações relatadas na Seção 2.9.3: funcionários do banco, compra acima de R$ 39,00, uma bebida na próxima visita e apresentação do cupom fiscal. O escopo é informativo, sem registrar concessões ou resgates individuais nem validar automaticamente o direito ao benefício. |
| RF25 | O sistema deve permitir registrar e consultar manualmente uma escala, com identificação do registro, pessoa identificada por código e nome, setor, vínculo, período e indicação dos dias de trabalho e folga. O exemplo da Seção 2.10 utiliza uma semana-modelo sem datas reais, com 15 pessoas e nomes fictícios; para uso operacional, esses dados devem corresponder às informações fornecidas pela unidade ou pelas prestadoras. O requisito abrange registro e consulta, sem geração automática de escala ou controle de presença. |

RF24 e RF25 definem os registros solicitados pelo grupo. Sua inclusão como requisitos não significa que esses registros já estejam implementados ou representados nas seis entidades do modelo atual. A estrutura desses dados ainda deverá ser alinhada ao dicionário e ao DER, preservando o caráter fictício do exemplo e as condições desconhecidas das campanhas como pendências.

## 3.2 Requisitos Não Funcionais

| Código | Requisito detalhado e verificação prevista |
|---|---|
| RNF01 | **Usabilidade:** os campos de cadastro, pedido e pagamento devem apresentar rótulos correspondentes ao dicionário. Mensagens de validação devem identificar o campo e o problema, como ausência de `nome`, `quantidade` inválida ou falta de `totem` na origem TOTEM. O `valor_total` deve ser apresentado como calculado. |
| RNF02 | **Integridade:** os vínculos entre `id_cliente`, `id_funcionario`, `id_pedido`, `id_produto`, `id_cupom_fiscal` e `id_pagamento` devem permanecer consistentes. Devem ser verificadas unicidade, obrigatoriedade, domínios e condições definidas nas regras de negócio, incluindo quantidades, preços, pagamentos e quitação. |
| RNF03 | **Segurança:** a consulta e a alteração de dados pessoais, cadastrais e financeiros — como `nome`, `cpf_cnpj`, preços e dados dos pagamentos — devem respeitar as permissões por operação previstas em RF23. A auditoria dessas operações deve seguir RF22, evitando dados pessoais desnecessários e impedindo que perfis operacionais editem ou apaguem logs. Os perfis e suas atribuições, propostos nas Seções 6.1 e 6.2 do dicionário HTML, ainda precisam ser confirmados com a unidade, incluindo os acessos técnicos de TOTEM e DELIVERY. |
| RNF04 | **Desempenho:** consultas de pedidos por identificador e consolidações por período devem ter seus tempos medidos, informando quantidade de pedidos, produtos e pagamentos e número de usuários simultâneos. Os limites aceitáveis de resposta ainda precisam ser definidos com a unidade. |
| RNF05 | **Disponibilidade:** durante a operação, devem estar acessíveis os dados necessários ao registro e acompanhamento do pedido, incluindo produtos, quantidades, preços, situação do preparo, documento fiscal e pagamentos. A janela de funcionamento e a meta de disponibilidade precisam ser confirmadas. |
| RNF06 | **Escalabilidade:** o sistema deve suportar o crescimento dos cadastros e dos registros de pedidos, produtos associados, cupons e pagamentos, preservando integridade e desempenho. Os volumes de referência e os critérios de crescimento precisam ser definidos a partir do levantamento real. |

Não foram atribuídos tempos de resposta, percentuais de disponibilidade ou volumes de operação sem confirmação da organização.

## 3.3 Correspondência das operações com o dicionário HTML

| Operação explicitada | Requisitos e regras relacionados | Referência no dicionário |
|---|---|---|
| Cadastrar ou alterar o nome e o preço atual de um produto, preservando seu identificador e o preço histórico das vendas. | RF04, RF08, RN04, RN12 e RNF03. | Entidade [PRODUTO](./index.html) e matriz de acesso da [Seção 6.2](./index.html#permissoes-retencao). |
| Atualizar a situação de preparo e entrega de um pedido, condicionando a liberação ao pagamento integral. | RF05, RF15, RF17, RF21, RN22 e RNF02. | Entidade [PEDIDO](./index.html) e operação de atualização do preparo na [Seção 6.2](./index.html#permissoes-retencao). |
| Registrar eventos e consultar logs conforme autorização, distinguindo o resultado da operação da situação do pagamento. | RF22, RF23 e RNF03. | [Seção 5 — Logs de acesso e operações](./index.html#logs-auditoria). |
| Autorizar ou negar operações conforme o perfil e a matriz de acesso, com registro das tentativas negadas. | RF23, RF22 e RNF03. | [Seção 6.1 — Perfis e Seção 6.2 — Matriz de acesso](./index.html#permissoes-retencao). |

RF22 e RF23 formalizam propostas já documentadas no HTML; sua redação não significa que autenticação, perfis e auditoria estejam implementados ou confirmados pela organização. Os campos de log não integram as seis entidades e os 30 atributos do modelo atual e ainda dependem de modelagem própria.

No balcão, a identificação de uma sessão compartilhada não comprova qual funcionário executou pessoalmente uma ação e não torna `PEDIDO.id_funcionario` obrigatório. O controle de acesso deve preservar RF06 e RN08. Consultas ou exportações que não estejam expressamente autorizadas na matriz devem ser negadas até sua definição.

O estoque permanece como lacuna em aberto na Seção 2.9.2; os requisitos acrescentados nesta revisão não definem controle de saldo, reservas ou movimentações de produtos.

---

# 4. Regras de Negócio

## 4.1 Regras Operacionais

As regras utilizam o prefixo `RN` e referenciam os requisitos que justificam sua existência.

| Código | Regra detalhada | Requisitos relacionados |
|---|---|---|
| RN01 | Os identificadores próprios `id_cliente`, `id_funcionario`, `id_pedido`, `id_produto`, `id_cupom_fiscal` e `id_pagamento` são obrigatórios e únicos nas respectivas entidades. | RF01, RF02, RF04, RF05, RF09, RF20 |
| RN02 | CLIENTE deve possuir `nome` obrigatório. O atributo `cpf_cnpj` é opcional e, quando informado, não pode se repetir em outro cadastro de cliente. | RF01 |
| RN03 | FUNCIONARIO deve possuir `nome` e `cargo` obrigatórios. Quando houver associação de um pedido a um funcionário, esse funcionário deve existir no cadastro; a associação não é obrigatória para realizar vendas no balcão. | RF02, RF05 |
| RN04 | PRODUTO deve possuir `nome` e `preco` obrigatórios. O preço atual de venda deve ser maior que zero. | RF04 |
| RN06 | PEDIDO deve possuir `data_hora`, `origem_pedido` e `status_preparo` obrigatórios, além de seu identificador. O vínculo com CLIENTE é opcional. | RF05 |
| RN07 | `origem_pedido` admite somente TOTEM, BALCÃO ou DELIVERY. Quando a origem for TOTEM, `totem` é obrigatório e identifica o equipamento utilizado; nas demais origens, não é preenchido. | RF05, RF06 |
| RN08 | Quando `origem_pedido` for BALCÃO, o atendimento utiliza um registro que permanece aberto para as vendas, sem exigir a identificação individual do funcionário em cada pedido. O vínculo por `id_funcionario` é opcional. | RF02, RF05, RF06 |
| RN09 | A ausência de cliente cadastrado ou de `cpf_cnpj` não impede o registro do pedido. Não se deve criar um cliente fictício apenas para permitir a venda ou a chamada. | RF01, RF05, RF19 |
| RN10 | `nome_comanda` pertence ao pedido e pode ser informado com ou sem cliente associado. Quando ausente, a identificação e a chamada utilizam `id_pedido`. Se o nome for copiado de CLIENTE, o registro da comanda preserva a identificação utilizada naquela compra. | RF05, RF19 |
| RN11 | Todo pedido deve conter pelo menos um produto cadastrado, por um único relacionamento CONTÉM entre PEDIDO e PRODUTO. Em cada associação, `quantidade` é obrigatória, inteira e maior que zero. | RF04, RF05, RF07 |
| RN12 | Cada associação de CONTÉM deve registrar `preco_unitario`, correspondente ao preço praticado naquela venda. Alterações posteriores em `PRODUTO.preco` não devem modificar esse preço histórico. | RF04, RF08 |
| RN13 | `PEDIDO.valor_total` é derivado da soma de `quantidade × preco_unitario` dos produtos associados. O valor não é informado livremente e não depende de um atributo de subtotal. | RF05, RF07, RF08, RF17 |
| RN14 | Cada pedido gera exatamente um CUPOM_FISCAL, e cada cupom pertence a um único pedido. O `id_pedido` do cupom é obrigatório e único, impedindo que dois cupons sejam associados ao mesmo pedido neste recorte. | RF20 |
| RN15 | CUPOM_FISCAL deve possuir `numero` e `data_hora_emissao` obrigatórios. O número é único no escopo da unidade analisada. | RF20 |
| RN16 | Cada cupom possui um ou mais registros de PAGAMENTO. Cada pagamento pertence a um único cupom, identificado obrigatoriamente por `id_cupom_fiscal`. | RF09, RF10, RF20 |
| RN17 | PAGAMENTO deve registrar obrigatoriamente `forma_pagamento`, `valor_pagamento`, `status_pagamento` e `data_hora_pagamento`. A forma admite PIX, Crédito, Débito ou Dinheiro; o valor deve ser maior que zero. A situação admite Aprovado ou Recusado, além de Estornado no tratamento proposto de devolução confirmada. | RF09, RF10, RF18 |
| RN18 | A divisão da conta gera registros de pagamento separados, cada um com sua forma e seu valor, mantendo todos vinculados ao mesmo cupom e, por ele, ao mesmo pedido. | RF09, RF10 |
| RN19 | O valor pago corresponde exclusivamente à soma de `valor_pagamento` dos registros com `status_pagamento = Aprovado`. Na ausência de aprovados, o resultado é zero. Recusados e Estornados não compõem essa soma. | RF09, RF17 |
| RN20 | Um pedido somente é considerado quitado quando o valor pago corresponde exatamente a `valor_total`. Valor inferior indica pendência; valor superior indica divergência a conciliar. | RF17 |
| RN21 | Uma tentativa recusada permanece no histórico e permite outra tentativa com novo `id_pagamento`, vinculada ao mesmo cupom. A recusa não cancela automaticamente o pedido nem desfaz pagamentos anteriormente aprovados. | RF09, RF10, RF17 |
| RN22 | `status_preparo` representa RECEBIDO, EM_PREPARO, PRONTO ou ENTREGUE. A liberação para preparo exige quitação. A entrega é identificada pelo `nome_comanda` ou pelo número `id_pedido`. | RF05, RF17, RF19, RF21 |
| RN23 | **Proposta a validar:** o cancelamento registra CANCELADO em `status_preparo` e impede a continuidade do atendimento, mesmo quando o valor pago corresponde ao total. Os estágios permitidos para cancelar dependem de confirmação com a unidade. | RF18 |
| RN24 | **Proposta a validar:** um pagamento aprovado passa para Estornado somente após a confirmação da devolução integral de seu `valor_pagamento`. Até essa confirmação, permanece Aprovado e representa devolução pendente. Pagamentos recusados não exigem estorno. Pedido, cupom e pagamentos são preservados no histórico. | RF09, RF18 |

### 4.1.1 Situação financeira e cancelamento

O valor pago é calculado por `soma(valor_pagamento)` dos registros cujo `status_pagamento` seja **Aprovado**, vinculados ao CUPOM_FISCAL do pedido. Na ausência de pagamentos aprovados, o resultado é zero. Registros **Recusado** ou **Estornado** não entram nessa soma. O valor pago e a situação financeira são informações derivadas em consulta, sem novos atributos armazenados em PEDIDO.

| Condição | Situação do pedido |
|---|---|
| Valor pago igual a zero | Sem valor pago; não quitado. |
| Valor pago maior que zero e menor que `valor_total` | Parcialmente pago; permanece pendente pelo valor restante. |
| Valor pago igual a `valor_total`, sem cancelamento | Quitado; apto à liberação para preparo. |
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
| O grupo informou um único fornecimento inteiramente vinculado à empresa e retirou compras e o cadastro de fornecedor do recorte. | RF13, RN05 e a entidade FORNECEDOR foram retirados da descrição vigente no README, sem reutilizar os códigos. A responsabilidade por compras e abastecimento ainda deve ser confirmada, conforme a Seção 2.9. |
| Limpeza e segurança são terceirizadas, segundo informação complementar do grupo. | Os processos são mapeados mesmo sem gestão direta da equipe. O exemplo de escala é fictício; contratos, horários reais e dados necessários ao acompanhamento ainda dependem de levantamento. |
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
| id_funcionario | Funcionário cadastrado associado ao pedido, quando esse vínculo for registrado | Opcional (FK); não é exigido para registrar vendas no balcão |
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

## 5.7 Atributos do relacionamento CONTÉM

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
| FUNCIONARIO | Representa os funcionários cadastrados, que podem ser associados aos pedidos de balcão que registrarem; o vínculo é opcional. |
| PEDIDO | Representa a realização de uma compra e registra sua origem e o totem utilizado, quando aplicável. |
| PRODUTO | Representa os alimentos e bebidas comercializados. |
| CUPOM_FISCAL | Representa o documento fiscal gerado por todo pedido e que gera os registros de pagamento. |
| PAGAMENTO | Registra os pagamentos vinculados ao cupom fiscal do pedido, inclusive pagamentos divididos. |

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

Obrigatoriedade, opcionalidade e uso condicional são restrições complementares: por exemplo, `cpf_cnpj` e `id_funcionario` são opcionais, `totem` é obrigatório somente quando a origem for TOTEM e `nome_comanda` pode ser omitido quando a chamada utiliza o número do pedido.

As indicações de PK e FK no dicionário antecipam o mapeamento para o modelo lógico relacional. Em uma representação conceitual estrita em Chen, as ligações entre entidades são expressas pelos relacionamentos e suas cardinalidades, sem repetir as FKs como atributos conceituais. Assim, os campos marcados como FK neste dicionário servem de referência para a implementação; os identificadores próprios continuam identificando suas respectivas entidades.

## 6.3 Relacionamentos pertinentes

| Relacionamento | Descrição | Cardinalidade |
|---|---|---|
| CLIENTE — REALIZA — PEDIDO | Um cliente pode realizar vários pedidos; o cliente associado é opcional. | 1:N |
| FUNCIONARIO — REGISTRA — PEDIDO | Um funcionário pode ser associado a vários pedidos de balcão que registrar; um pedido pode não ter funcionário associado. | 1:N |
| PEDIDO — CONTÉM — PRODUTO | Único relacionamento entre pedido e produto, com quantidade e preço unitário da venda. | N:M |
| PEDIDO — GERA — CUPOM_FISCAL | Todo pedido gera exatamente um cupom, e cada cupom pertence a um pedido. | 1:1 |
| CUPOM_FISCAL — GERA — PAGAMENTO | Um cupom gera um ou mais pagamentos, e cada pagamento pertence a um único cupom. | 1:N |

## 6.4 Restrições aplicadas ao modelo

- A origem do pedido deve ser TOTEM, BALCÃO ou DELIVERY.
- `totem` é um atributo de PEDIDO e identifica o equipamento quando a origem é TOTEM; não existe entidade TOTEM.
- `id_funcionario` é opcional, inclusive quando a origem é BALCÃO: o atendimento utiliza um registro que permanece aberto para as vendas, sem exigir identificação individual em cada pedido. Pedidos de DELIVERY também não exigem funcionário de balcão nem identificação de totem.
- Todo pedido gera um CUPOM_FISCAL, e os pagamentos são vinculados a esse documento fiscal.
- O cupom pode gerar múltiplos pagamentos para representar divisão da conta.
- Somente pagamentos aprovados compõem o valor pago; a quitação exige igualdade com o total do pedido. Cancelamento e estorno seguem a Seção 4.1.1.
- Há apenas um relacionamento CONTÉM entre PEDIDO e PRODUTO, com `quantidade` e `preco_unitario`. `valor_total` é derivado da soma dos produtos desses dois valores.

---

# 7. Diagrama Entidade-Relacionamento (DER)

## 7.1 DER da We Coffee

![DER da We Coffee com pedido, produto, cupom fiscal e pagamento](<./WECOFFE/Modelo_Conceitual_WeCoffee_BRModelo.png>)

[Arquivo editável no brModelo 3](<./WECOFFE/modelagem/Modelo_Conceitual_WeCoffee.brM3>)

O DER, o arquivo editável brModelo e as exportações PNG, JPG e PDF apresentam **seis entidades, cinco relacionamentos e 26 atributos conceituais**, sem FORNECEDOR. O dicionário documenta **30 atributos**: 26 conceituais e quatro referências de FK para o modelo lógico. O HTML está alinhado a essas contagens e trata `PEDIDO.id_funcionario` como opcional, inclusive nas vendas de balcão. O registro manual de escala solicitado em RF25, exemplificado na Seção 2.10, ainda não está representado no DER; sua representação permanece pendente de modelagem. Nomes, códigos e dias do exemplo continuam fictícios.

O abastecimento diário e o registro informativo de campanhas previsto em RF24 ainda não possuem representação específica no modelo. O controle quantitativo de estoque permanece como lacuna em aberto, sem solução definida nesta versão. Concessão e resgate de benefícios não integram RF24 nesta etapa. Os registros de campanha e escala foram incluídos nos requisitos por solicitação do grupo, mas ainda precisam ser representados no dicionário e no DER; as contagens acima descrevem os artefatos atuais.

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
| Escolha das entidades | Foram preservados os cadastros de clientes, funcionários e produtos, além do pedido e do pagamento; CUPOM_FISCAL representa o documento gerado por todo pedido. O cadastro de fornecedor foi retirado do recorte conforme justificativa da Seção 2.9. |
| PEDIDO como entidade central | O pedido conecta o processo de venda aos produtos e ao documento fiscal, com vínculos opcionais ao cliente e ao funcionário cadastrado. |
| Relacionamento único PEDIDO — CONTÉM — PRODUTO | Representa a relação N:M e registra quantidade e preço histórico como atributos do relacionamento. |
| CUPOM_FISCAL entre PEDIDO e PAGAMENTO | Explicita a regra de que todo pedido gera um documento fiscal e que os pagamentos são vinculados a ele. |
| CUPOM_FISCAL — GERA — PAGAMENTO em 1:N | Permite representar mais de uma forma de pagamento para o mesmo documento fiscal. |
| `valor_pagamento` | Registra quanto foi pago em cada parte quando a conta é dividida. |
| `origem_pedido` | Diferencia TOTEM, BALCÃO e DELIVERY. |
| `totem` como atributo de PEDIDO | Identifica o equipamento utilizado no autoatendimento, sem manter entidade própria. |
| FUNCIONARIO opcional em PEDIDO | Permite associar um funcionário cadastrado ao pedido, sem exigir `id_funcionario` em cada venda de balcão, pois o atendimento utiliza um registro que permanece aberto para as vendas. |
| Quitação calculada a partir de PAGAMENTO | A consulta passa pelo CUPOM_FISCAL; somente valores aprovados compõem o valor pago. |
| Retirada de FORNECEDOR | O grupo informou fornecimento único vinculado à empresa e retirou o cadastro e a funcionalidade de compras do recorte. Isso não elimina a necessidade de levantar abastecimento e recebimento; a decisão e a limitação estão registradas na Seção 2.9. |

## 8.2 Por que não outras alternativas?

| Alternativa | Motivo da rejeição |
|---|---|
| Usar apenas o preço atual de PRODUTO para consultar vendas anteriores | Não preservaria o preço praticado em cada venda; esse valor é mantido em `preco_unitario` do relacionamento CONTÉM. |
| CUPOM_FISCAL 1:1 PAGAMENTO | Não representaria a possibilidade de dividir a conta entre diferentes formas de pagamento. |
| Criar uma entidade para cada origem do pedido | As origens são representadas por `origem_pedido`, e o equipamento de autoatendimento é registrado em `totem`. |
| Manter cadastro e seleção de múltiplos fornecedores | O grupo informou fornecimento único vinculado à empresa e solicitou sua retirada do recorte. Quem administra compras e abastecimento ainda precisa ser confirmado; a exclusão não foi apresentada como prova de inexistência desses processos. |

## 8.3 Justificativa do DER

O DER representa o pedido, seus produtos, o documento fiscal e os pagamentos. O relacionamento único PEDIDO — CONTÉM — PRODUTO registra as quantidades e o preço praticado na venda. O atributo derivado `valor_total` resulta da soma de `quantidade × preco_unitario` de cada produto associado.

Todo PEDIDO gera exatamente um CUPOM_FISCAL, e esse documento gera um ou mais PAGAMENTOS. A divisão da conta é preservada, e somente valores aprovados compõem a quitação do pedido. Tentativas recusadas e o tratamento proposto de cancelamento e estorno seguem a Seção 4.1.1.

A origem é registrada em `origem_pedido`, com TOTEM, BALCÃO ou DELIVERY. Quando a origem é TOTEM, o atributo `totem` registra o equipamento utilizado. Os cadastros de CLIENTE e FUNCIONARIO são preservados. A retirada de FORNECEDOR está descrita na Seção 2.9 e foi refletida nos arquivos do DER e no HTML.

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

## 9.1 Pesquisa de processos típicos e geração da escala — 28/10/2026

| Item | Registro desta revisão |
|---|---|
| Ferramenta e finalidade | Codex, com pesquisa na web, para conferir processos comuns em cafeterias, explicitar lacunas do levantamento e gerar uma escala demonstrativa. |
| Solicitação do grupo | Conferir se já existia escala no projeto e, na ausência, criar uma escala fictícia 6x1 com folgas predominantemente durante a semana. O grupo confirmou em 28/10/2026 a composição de oito pessoas da cafeteria, quatro da limpeza e três da segurança, sendo os dois últimos serviços terceirizados. Os códigos individuais e a distribuição dos dias são fictícios; nomes também fictícios foram acrescentados posteriormente, conforme o registro da Seção 9.4. |
| Fonte efetivamente consultada | [Sebrae/ASN — perfil das cafeterias brasileiras, 20/05/2024](https://agenciasebrae.com.br/dados/muito-alem-do-cafezinho-com-pao-de-queijo-conheca-o-perfil-das-cafeterias-brasileiras/), consultado em 28/10/2026. O estudo aborda equipe, preparo, padrões de qualidade, fornecedores e comunicação com clientes; não descreve a operação específica desta unidade. |
| Resultado recebido | Matriz de processos incluídos, terceirizados e ainda não confirmados; justificativa do recorte de compras/fornecedor; semana-modelo com 15 códigos fictícios e totais diários. |
| Verificação | Busca nos arquivos não encontrou escala anterior. Na simulação, cada pessoa possui seis dias T e um F; 14 das 15 folgas ficam entre segunda e sexta. Os totais por setor são calculados a partir das marcações, sem afirmar cobertura por turno. |
| Limites e decisão do grupo | Não foram inventados nomes reais, entrevista, horários, contratos ou confirmações da unidade. A escala não foi apresentada como cadastro já existente no banco. A retirada do fornecedor não foi usada para afirmar que abastecimento e recebimento deixam de existir. |
| Pendências | Obter a escala real, registrar a atualização da composição no levantamento, levantar os processos ainda ausentes e refletir as decisões aprovadas nos requisitos, dicionário e DER. Não houve nova visita nesta revisão. |

O esqueleto fornecido pelo professor menciona a seção 6 para o registro de IA. Neste README, a seção existente de Uso de Inteligência Artificial é a **9**, onde o registro foi acrescentado sem renumerar as demais seções.

## 9.2 Complementação dos processos e lacunas do levantamento — 28/10/2026

| Item | Registro desta revisão |
|---|---|
| Ferramenta e finalidade | Codex, para documentar as informações complementares do grupo sobre contas a pagar, perdas, validade, abastecimento diário e campanhas de parceria, além de sugerir um controle de estoque. |
| Solicitação do grupo | Informou falta de acesso a contas a pagar e perdas; ausência de controle específico de validade justificada pela reposição diária; abastecimento todos os dias; campanhas quase mensais e o benefício CITI de uma bebida na próxima visita mediante cupom de compra acima de R$ 39,00. Pediu sugestão para estoque. |
| Fonte primária das informações da unidade | Relato do grupo nesta conversa, em 28/10/2026. Não houve nova visita, acesso aos sistemas internos nem verificação de regulamento promocional nesta revisão. |
| Fonte externa consultada | [Anvisa — Cartilha de Boas Práticas para Serviços de Alimentação](https://www.gov.br/anvisa/pt-br/centraisdeconteudo/publicacoes/alimentos/manuais-guias-e-orientacoes/cartilha-boas-praticas-para-servicos-de-alimentacao.pdf), consultada em 28/10/2026, para distinguir reposição diária de conferência de validade e identificação de alimentos armazenados. A fonte é orientação geral, não evidência da prática da unidade. |
| Resultado recebido | Atualização da matriz de processos, registro dos limites de acesso e detalhamento do benefício CITI. Foi apresentada uma proposta de estoque, mas o grupo decidiu adiar sua definição e manter o tema como lacuna em aberto. |
| Verificações e limites | Preservada a condição estrita de compra acima de R$ 39,00. Não foram inventados prazos, bebidas participantes, método de comprovação, programa do aplicativo ou quantidades de perdas. A definição do estoque, incluindo o momento de baixa, foi adiada pelo grupo. Posteriormente, o grupo limitou a campanha a registro informativo, sem funcionalidade de concessão ou resgate, conforme RF24 e a Seção 9.4. |
| Decisão nesta revisão | Incorporar os relatos ao mapeamento do README e manter o estoque como lacuna em aberto, a retomar posteriormente, sem adotar a proposta apresentada. Nenhuma entidade, atributo, requisito vigente ou artefato visual foi alterado para representar controle de estoque. |
| Pendências | Retomar a discussão do estoque e confirmar os dados de recebimento e controle quantitativo antes de definir sua modelagem. Confirmar cuidados de validade, regras completas de campanhas e eventual programa do aplicativo. Contas a pagar e perdas permanecem sem acesso; a ampliação dos requisitos, do dicionário e do DER depende de validação. |

## 9.3 Explicitação de operações e vínculo com o dicionário — 28/10/2026

| Item | Registro desta revisão |
|---|---|
| Ferramenta e finalidade | Codex, para comparar os requisitos do README com as operações e propostas já documentadas no dicionário HTML. |
| Solicitação do grupo | Explicitar atualização do preparo, alteração de produtos e preços e relação dos logs e das permissões com os requisitos. |
| Material conferido | Seções 2.6, 3 e 4 do README e entidades, logs, perfis e matriz de acesso do dicionário HTML v1.2. Não houve pesquisa externa, nova entrevista ou validação operacional nesta revisão. |
| Resultado | RF04 ampliado; RF21, RF22 e RF23 acrescentados; RNF03 detalhado; referências de RN12 e RN22 atualizadas e quadro de correspondência incluído na Seção 3.3. |
| Verificação e limites | Preservados o preço histórico, a quitação para liberação ao preparo e o vínculo opcional com funcionário no balcão. Auditoria e perfis continuam como propostas a validar, sem nova entidade ou alteração dos artefatos visuais. |
| Decisão e pendências | Formalizar as operações no README. Confirmar posteriormente perfis, acessos técnicos e modelagem da auditoria com a unidade. O estoque permanece como lacuna em aberto. |

## 9.4 Registros de campanha e escala com nomes fictícios — 28/10/2026

| Item | Registro desta revisão |
|---|---|
| Ferramenta e finalidade | Codex, para limitar a campanha a registro informativo e formalizar o registro manual da escala, incluindo nomes fictícios no exemplo. |
| Solicitação do grupo | Tratar a campanha CITI apenas como registro, mantendo condições desconhecidas pendentes, e incluir a escala como funcionalidade de registro com nomes fictícios. |
| Material conferido | Processos e requisitos do README e decisões anteriores do grupo sobre composição da equipe e distribuição fictícia das folgas. Não houve nova pesquisa externa, entrevista ou confirmação da escala real. |
| Resultado | RF24 e RF25 incluídos; referências de escopo ajustadas; tabela com nomes fictícios para oito pessoas da cafeteria, quatro da limpeza e três da segurança. |
| Verificação e limites | Preservados os códigos, os dias de trabalho/folga e os totais diários. Os nomes são fictícios; não foram inventadas datas reais, condições promocionais ou dados pessoais dos funcionários da unidade. |
| Decisão e pendências | Incluir registro e consulta manual como requisitos. Campanhas não terão concessão ou resgate automático ou individual nesta etapa. A representação dos dois registros no dicionário e no DER permanece pendente; estoque continua em aberto. |

---
- **Participação (10%):** envolvimento nas discussões técnicas e nas decisões do grupo.
- **Comprometimento (8%):** cumprimento de prazos e responsabilidades assumidas.
- **Colaboração (4%):** respeito às contribuições dos colegas, cooperação na construção do projeto e colaboração equilibrada no histórico de commits do repositório GitHub.
- **Autonomia (7%):** busca independente de soluções e proposta de melhorias.

----

# Conclusão

O modelo conceitual descrito no README representa atendimento, pedidos, produtos, documentos fiscais, pagamentos, preparação e entrega, preservando os cadastros de clientes e funcionários. O cadastro de fornecedor foi retirado do recorte documental. O mapeamento também registra organização da equipe, limpeza e segurança, abastecimento diário, limitações de acesso a contas a pagar e perdas, relato sobre validade e campanhas de parceria. O estoque permanece como lacuna em aberto, cuja definição foi adiada pelo grupo. Os requisitos RF24 e RF25 contemplam apenas o registro informativo de campanhas e o registro manual de escala, demonstrado com nomes fictícios. Sua representação no dicionário e no DER permanece pendente; concessão e resgate de benefícios não integram esta etapa.

A modelagem foi estruturada para manter consistência entre os processos levantados, os requisitos, as regras de negócio, o dicionário de dados e o DER.

---

## Alterações

### Registros informativos de campanha e escala — 28/10/2026

- Incluído RF24 para registro e consulta das informações conhecidas das campanhas, sem funcionalidade de concessão ou resgate de benefícios.
- Incluído RF25 para registro e consulta manual de escala; acrescentados 15 nomes fictícios ao exemplo 6x1, preservando códigos, folgas, setores e totais diários.
- Ajustadas as referências de escopo e registrado o uso de IA na Seção 9.4. Dicionário e DER ainda precisam representar os registros aprovados como requisitos.
- Mantidos o estoque como lacuna em aberto e os demais requisitos. Somente o README foi alterado nesta revisão.

### Explicitação de operações nos requisitos — 28/10/2026

- Ampliado RF04 para alteração do nome e do preço atual de produtos, mantendo identificador e preço histórico.
- Acrescentado RF21 para atualização do preparo e da entrega, com liberação condicionada à quitação.
- Acrescentados RF22 e RF23 para auditoria e controle de acesso como propostas a validar; detalhado RNF03 e incluídas referências às seções correspondentes do HTML.
- Atualizadas as referências de RN12 e RN22 e registrado o uso de IA na Seção 9.3.
- Mantidos o estoque como lacuna em aberto, o vínculo opcional com funcionário no balcão e as contagens do modelo. Somente o README foi alterado nesta revisão.

### Complementação dos processos de negócio — 28/10/2026

- Registrados contas a pagar e perdas como informações não acessíveis ao grupo, sem afirmar inexistência dos processos.
- Confirmado abastecimento diário pelo relato do grupo e documentada a justificativa informada sobre validade, com referência à orientação da Anvisa.
- Apresentada uma proposta de controle de estoque; posteriormente, por decisão do grupo, seu detalhamento foi retirado da seção vigente e o tema foi mantido como lacuna em aberto, a retomar em outra etapa.
- Documentadas campanhas de parceria e a bebida concedida a funcionários do CITI na próxima visita, mediante cupom de compra acima de R$ 39,00; regras complementares e programas do aplicativo continuam pendentes.
- Mantidos os requisitos e as seis entidades do modelo vigente; HTML, DER e demais arquivos não foram alterados nesta revisão.

### Alinhamento do HTML e do DER — 28/10/2026

- Retirados FORNECEDOR, id_fornecedor e cnpj do dicionário HTML e do DER, preservando os demais cadastros e relacionamentos.
- Atualizadas as contagens para seis entidades, cinco relacionamentos, 26 atributos conceituais e 30 atributos documentados, incluindo quatro referências de FK.
- Tornado opcional o vínculo por PEDIDO.id_funcionario no HTML, inclusive nas vendas de balcão, conforme RF02, RF06, RN03 e RN08.
- Atualizados o arquivo editável .brM3 e as versões PNG, JPG e PDF, com reabertura do modelo nativo e conferência visual. Dicionário HTML atualizado para v1.1.

### Apresentação dos atributos no DER — 27/10/2026

- Incluídos todos os atributos conceituais no desenho, seguindo a disposição visual do exemplo fornecido e preservando as sete entidades e os cinco relacionamentos vigentes.
- Adicionado o arquivo editável `.brM3`, validado por reabertura no motor do brModelo, e atualizadas as versões PDF, PNG e JPG.
- Esclarecida a contagem de 28 atributos conceituais e quatro referências de FK no dicionário, sem alteração das regras de negócio.

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
