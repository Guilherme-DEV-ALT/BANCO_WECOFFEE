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

## 1.1 Contexto e porte

Conforme atualização confirmada pelo grupo em **28/10/2026**, a composição informada é de **8 funcionários da cafeteria, 4 profissionais de limpeza terceirizada e 3 seguranças terceirizados**, totalizando **15 pessoas**. Essa informação substitui a estimativa anterior de aproximadamente seis funcionários da cafeteria.

**Limite dos números disponíveis:** o grupo não dispõe de quantidade real de clientes cadastrados, pedidos por dia/mês, produtos do cardápio ou saldos de estoque. Em 01/11/2026, autorizou o uso de uma amostra fictícia para a massa de dados. Os números da Seção 4 da Entrega 2 são dimensões da amostra de testes, não estimativas de volume real. Os oito funcionários da cafeteria são o parâmetro de porte efetivamente confirmado para dimensionar FUNCIONARIO; os sete terceirizados não são adicionados a esse cadastro operacional.

As quantidades de cada grupo foram confirmadas nesta conversa. A distribuição dos dias de trabalho e das folgas apresentada na Seção 2.10 continua sendo **fictícia**, sem representar a escala real da unidade ou das prestadoras.

A unidade trabalha com diferentes formas de atendimento:

- **Totem de autoatendimento:** o próprio cliente realiza o pedido e o pagamento.
- **Balcão:** o funcionário registra o pedido e informa o nome do cliente. As vendas utilizam um registro que permanece aberto para o atendimento, sem solicitar `id_funcionario` a cada venda; o vínculo do pedido com um funcionário cadastrado é opcional.
- **Delivery:** o cliente realiza o pedido e o pagamento pela plataforma de entrega.
Após o registro do pedido, é gerada uma comanda para auxiliar no processo de preparação e entrega.

## Problemas e necessidades identificados

Durante a entrevista com o gerente da unidade, foi identificado que as informações de vendas podem ser consultadas, porém tem uma certa dificuldade para **consolidar essas informações em um fechamento mensal que permita avaliar claramente o desempenho da loja**.

Também foi observado que o controle de disponibilidade dos produtos depende da atualização do estoque. Quando um produto acaba, a equipe verifica a situação e atualiza sua disponibilidade para que os canais de venda reflitam a informação.

Dessa forma, o projeto busca estruturar os dados de pedidos, produtos, documentos fiscais e pagamentos para facilitar consultas e futuras análises gerenciais. O estoque de produtos prontos integra o modelo lógico e o SQL, conforme as regras confirmadas pelo grupo em 01/11/2026. Por orientação do grupo, não é desenhado no DER conceitual.

## Justificativa da escolha

A We Coffee foi escolhida por apresentar um cenário real de operações comerciais com diferentes canais de atendimento, vendas, pagamentos, controle de estoque e relacionamento com fornecedores. Sendo também uma empresa nova com apenas 5 anos, com objetivos de finalizar o ano com 20 unidades no total e se mostrando ser uma excelente oportunidade para aprendermos e crescermos junto com a empresa.

O grupo teve acesso à unidade e realizou entrevista com o gerente, além de observação dos processos e registros fotográficos.

## Evidências da organização

Foram obtidas evidências da existência e do acesso à organização, incluindo:

- endereço da unidade;
- site oficial;
- rede social da organização;
- contato do gerente da unidade: Daniel Porrino (+55 11 95208-6022)
- contato do auxiliar geral: Leandro Viana (responde por tudo quando o seu superior não está presente) | (+55 11 977707658)
- entrevista com o gerente;
- entrevista com o auxiliar geral;
- registros fotográficos da unidade.
- vídeos de fechamento de procesos.
- vídeos de como funciona o atendimento.
- como os atendimento são processado
- Link da loja: https://share.google/shs5jxNxnNAmYuQjz

![Foto do grupo durante a visita à unidade We Coffee](<./WECOFFE/Comprovante_Presença_WECOFFE.jpeg>)

![Foto do grupo no interior da unidade We Coffee](<./WECOFFE/Registro_Grupo_WeCoffee.jpeg>)

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

## 2.7 Cancelamento e estorno — procedimento confirmado na entrevista

Segundo o relato do auxiliar geral **Leandro Viana**, em entrevista realizada em **08/11/2026** e informada pelo grupo em **09/11/2026**, o procedimento envolve o **cancelamento da nota fiscal e do pedido**, com **estorno realizado na hora pelo cartão do cliente**. O sistema existente faz automaticamente o balanceamento dos valores e o estorno. Essa informação confirma o processo operacional antes tratado como proposta a validar.

No modelo acadêmico, o cancelamento é representado pelo estado **CANCELADO** em `PEDIDO.status_preparo`, impedindo a continuidade do preparo ou da entrega. O `status_pagamento` passa para **Estornado** após a confirmação efetiva da devolução. Pagamentos recusados não exigem estorno. O pedido, seu cupom e seus pagamentos permanecem no histórico; cancelamento não significa exclusão dos registros.

Como escolha técnica do recorte atual, cada registro de pagamento é estornado integralmente. Se a confirmação da devolução ainda não tiver sido recebida, o pagamento permanece **Aprovado** e a auditoria aponta devolução pendente. Esse é um estado de exceção para conferência, e não o fluxo normal de estorno imediato relatado na entrevista.

O SQL representa a situação do pedido e do pagamento, mas ainda não armazena a situação de cancelamento do documento fiscal nem o evento/data do estorno. A integração com os serviços fiscal e de cartão e o balanceamento automático do sistema existente não estão implementados no projeto. Permanecem a detalhar os estágios em que se pode cancelar, quem pode autorizar/operar o estorno, as regras para PIX e Dinheiro, pagamentos divididos ou estornos parciais e eventuais devoluções após um fechamento.

## 2.8 Consulta e análise de vendas

As consultas relacionam:

- **PEDIDO:** `id_pedido`, `data_hora`, `origem_pedido`, `nome_comanda`, `status_preparo` e `valor_total`;
- **PRODUTO e CONTÉM:** identificação e nome do produto, `quantidade` e `preco_unitario`;
- **CUPOM_FISCAL:** identificação do documento, `numero` e `data_hora_emissao`;
- **PAGAMENTO:** identificação da tentativa, `forma_pagamento`, `valor_pagamento`, `status_pagamento` e `data_hora_pagamento`.

Esses dados permitem consultar compras, documentos emitidos, pagamentos divididos, recusas, valores aprovados e situações financeiras.

Na consolidação mensal, um pedido com vários produtos ou pagamentos não deve ter seu total contado repetidamente. Conforme a entrevista de **08/11/2026** com o auxiliar geral, o **fechamento das vendas ocorre ao final de cada dia e é realizado exclusivamente pelos gerentes**. A consolidação mensal deve apoiar a análise dos resultados diários.

### 2.8.1 Confirmações e consequências para o projeto — 09/11/2026

| Informação confirmada na entrevista | Consequência no projeto |
|---|---|
| Fechamento ao final de cada dia. | Periodicidade diária formalizada em RF16, RF31 e RN33; a análise mensal continua sendo necessária. |
| Apenas gerentes realizam o fechamento. | Operação de fechamento restrita à Gerência na matriz de acesso. Consultar um relatório não equivale a executar um fechamento. |
| Cancelamento da nota fiscal e do pedido. | RF18 e RN23 passam a se apoiar no relato; o banco preserva o histórico. O registro específico da situação fiscal ainda exige ampliação do modelo. |
| Estorno na hora pelo cartão do cliente. | RF18 e RN24 deixam de tratar a existência desse procedimento como hipótese. A confirmação da devolução continua necessária para registrar Estornado. |
| O sistema existente faz o balanceamento e o estorno automaticamente. | Automação documentada como prática relatada da unidade; o SQL acadêmico não executa transações na operadora nem no sistema fiscal. |

**Referência temporal das consultas:** a periodicidade diária foi confirmada, mas a entrevista não definiu qual campo de data o sistema existente utiliza nem um horário exato de corte. As consultas acadêmicas continuam usando `PEDIDO.data_hora` para vendas e `PAGAMENTO.data_hora_pagamento` para tentativas, com início inclusivo e fim exclusivo. Para consultar um dia civil, usar o início desse dia e o início do seguinte. Esse filtro é uma convenção analítica do projeto, não uma confirmação do regime contábil ou de reabertura do fechamento da unidade.

O fechamento gerencial efetivo, com identificação do gerente, instante de execução e valores preservados, ainda não possui registro próprio no banco. Autenticação, bloqueio por perfil e preservação de fechamentos históricos permanecem pendentes de implementação. O vínculo opcional de funcionário no pedido de balcão não identifica nem autoriza o responsável pelo fechamento.

## 2.9 Conferência dos processos típicos e justificativas do recorte

A pesquisa sobre cafeterias foi utilizada para ampliar as perguntas do levantamento. O estudo do [Sebrae sobre o perfil das cafeterias brasileiras](https://agenciasebrae.com.br/dados/muito-alem-do-cafezinho-com-pao-de-queijo-conheca-o-perfil-das-cafeterias-brasileiras/) aborda preparo, qualificação da equipe, padrões de qualidade, fornecedores e relacionamento com clientes. Essas referências setoriais não comprovam como a We Coffee analisada realiza cada atividade. A matriz abaixo combina o relato já documentado, as informações complementares do grupo e os processos prováveis sugeridos pela pesquisa e pela IA.

| Processo | Situação na organização e dados envolvidos | Tratamento no trabalho e confirmação necessária |
|---|---|---|
| Cadastros de clientes, funcionários e produtos | Já descritos: identificadores, nomes, documento opcional do cliente, cargo e preço atual do produto. | Incluídos no modelo e detalhados nas Seções 2.1, 3 e 5. |
| Atendimento, pedido e venda | Já descritos: origem, equipamento quando aplicável, nome de comanda, produtos, quantidades e preços praticados. | Incluídos, independentemente de sua relação direta com o problema de fechamento mensal. |
| Documento fiscal e pagamentos | Número e data de emissão, forma, valor, situação e data de cada tentativa; cancelamento da nota e do pedido relatado na entrevista de 08/11/2026. | Incluídos. A ocorrência do cancelamento fiscal está confirmada; códigos, comprovantes, prazos e integração fiscal ainda precisam ser detalhados. |
| Preparação, separação e entrega | Já descritos: identificação do pedido e estados de preparo. | Incluídos. Receitas, ingredientes, produção de alimentos e procedimentos de qualidade ainda não foram detalhados. |
| Cancelamento e devolução financeira | Entrevista de 08/11/2026 confirma cancelamento da nota e do pedido, estorno na hora pelo cartão e balanceamento automático pelo sistema existente. | Processo confirmado; estados CANCELADO e Estornado representam seus efeitos no modelo. Permissões de estorno, outras formas de devolução e detalhes das integrações permanecem pendentes, conforme a Seção 2.7. |
| Fechamento de vendas | Entrevista de 08/11/2026 confirma fechamento ao final de cada dia, exclusivamente pelos gerentes; permanece a dificuldade de consolidação mensal. | Periodicidade e responsabilidade confirmadas em RF31/RN33. Horário exato de corte, abertura de caixa, despesas, conciliação detalhada e tratamento após o fechamento ainda precisam de levantamento. |
| Contas a pagar | O grupo não conseguiu acesso às informações desse processo. Valores, vencimentos, credores, responsáveis e situação dos pagamentos não foram disponibilizados. | Processo registrado como informação não acessível ao grupo, sem dados financeiros ou funcionalidade modelados. A falta de acesso não comprova inexistência nem permite afirmar como a atividade é executada. |
| Compras e cadastro de fornecedor | O grupo informou um único fornecimento totalmente vinculado à empresa e solicitou retirar compras e FORNECEDOR do recorte. | Retirados como funcionalidade e cadastro próprios desta versão. Ainda é necessário confirmar quem solicita, compra e autoriza o fornecimento, inclusive se a gestão é centralizada. O abastecimento diário está confirmado, independentemente da existência de um cadastro local de fornecedor. |
| Abastecimento e recebimento | O grupo confirmou em 28/10/2026 que o abastecimento ocorre todos os dias. Horários, produtos, quantidades recebidas, responsáveis e forma de conferência não foram detalhados. | Frequência incluída no mapeamento como informação do grupo. Não se presume que todos os produtos sejam repostos todos os dias, que não existam sobras ou que o recebimento já esteja representado no banco. |
| Disponibilidade e estoque | Controle de produtos prontos e baixa na liberação para preparo confirmados pelo grupo em 01/11/2026. | Definido na Seção 2.9.2 e implementado apenas nas camadas lógica e física, sem inclusão no DER conceitual. |
| Escala e organização da equipe | Nenhuma escala real foi localizada nos arquivos do projeto. O grupo solicitou um registro manual com pessoa, setor, vínculo, período e dias de trabalho/folga. | Funcionalidade de registro e consulta incluída em RF25, acompanhada de exemplo com 15 nomes e códigos fictícios na Seção 2.10. Datas, horários e distribuição real da equipe continuam pendentes de levantamento. |
| Limpeza e conservação | O grupo informou serviço terceirizado com quatro pessoas. Ambientes atendidos, tarefas, frequência e responsável pela prestação ainda precisam ser detalhados. | Processo incluído no mapeamento. O quadro fictício demonstra apenas a distribuição dos dias; não representa contrato, checklist ou escala real da prestadora. |
| Segurança | O grupo informou serviço terceirizado com três pessoas. Postos, horários, responsáveis e registros de ocorrências ainda não foram informados. | Processo incluído no mapeamento. Contratos e gestão de pessoal da prestadora não foram modelados; confirmar quais dados a unidade precisa acompanhar. |
| Validade dos produtos | Segundo o grupo, não há controle específico de validade no recorte levantado, tendo sido apresentada como justificativa a reposição diária. Não foram obtidos detalhes sobre conferência de prazos, rótulos ou tratamento das sobras. | Justificativa documentada como relato, sem concluir que a reposição diária dispensa a conferência de validade. Confirmar quem realiza essa verificação e onde ela é registrada, conforme a Seção 2.9.1. |
| Perdas e desperdício | O grupo não teve acesso às informações desse processo. Quantidades, motivos, datas e destinação das perdas não foram disponibilizados. | Registrado como limitação de acesso, sem afirmar perda zero ou inexistência de desperdício. O modelo lógico agora permite registrar perdas em unidades, sem supor acesso a ocorrências históricas reais. |
| Produção e controle de qualidade | Produtos preparados na unidade, ingredientes utilizados e procedimentos de qualidade ainda não foram detalhados. | Processo ainda a conferir. A reposição diária não permite inferir como ocorre a produção nem substituir o levantamento de qualidade e conservação. |
| Campanhas e parcerias | O grupo informou campanhas quase todos os meses, em função de parcerias com grandes empresas. Como exemplo, funcionários do banco CITI que gastam acima de R$ 39,00 recebem uma bebida na próxima visita, apresentando o cupom fiscal da compra. | Registro informativo incluído em RF24, conforme relato do grupo. O benefício é uma cortesia posterior; sua concessão e seu resgate não serão controlados pelo sistema nesta etapa. Condições ainda desconhecidas permanecem na Seção 2.9.3. |
| Programas do aplicativo | Não foram confirmados programa de pontos, cashback, cupons próprios do aplicativo ou regras de fidelidade digital. | Permanecem pendentes de levantamento. A campanha do CITI não foi atribuída ao aplicativo, e a existência do canal DELIVERY não comprova um programa de fidelidade. |
| Divulgação e eventos | A pesquisa setorial indica relacionamento e comunicação com clientes, mas não foram detalhados os canais de divulgação das campanhas nem a existência de eventos nesta unidade. | Não incluídos como funcionalidades ou entidades enquanto não houver confirmação. Registrar se são executados pela unidade, pela empresa ou por terceiros. |

**Limite de cobertura:** ter um fornecedor único ou terceirizar um serviço não elimina a necessidade de mapear a atividade. As informações iniciais foram fornecidas pelo grupo em 28/10/2026 e o estoque foi atualizado em 01/11/2026, nesta conversa. Em 09/11/2026, o grupo acrescentou o relato da entrevista com o auxiliar geral realizada em 08/11/2026, confirmando fechamento diário e estorno pelo cartão. O assistente não participou da entrevista nem acessou registros internos. Contas a pagar e perdas permanecem documentados como informações não acessíveis, e não como processos inexistentes. Os processos confirmados ainda sem representação no modelo exigem posterior detalhamento dos requisitos, do dicionário e do DER.

### 2.9.1 Limites do levantamento e validade

O grupo informou que não conseguiu acesso aos dados de contas a pagar nem aos registros de perdas. Por esse motivo, o trabalho não descreve valores, documentos, responsáveis ou procedimentos desses processos. Essa limitação deve permanecer explícita na avaliação da cobertura do levantamento.

Sobre validade, o relato recebido foi de ausência de controle específico, justificada pela reposição diária. O abastecimento diário foi confirmado, mas não foram confirmados prazo de uso, data de preparo, identificação dos produtos ou destino das sobras. Assim, não se afirma que os produtos não tenham validade nem que todos sejam consumidos ou descartados no mesmo dia.

Como referência para a próxima conferência, a [cartilha de Boas Práticas para Serviços de Alimentação da Anvisa](https://www.gov.br/anvisa/pt-br/centraisdeconteudo/publicacoes/alimentos/manuais-guias-e-orientacoes/cartilha-boas-praticas-para-servicos-de-alimentacao.pdf) orienta verificar as condições e os prazos dos alimentos recebidos e identificar alimentos preparados armazenados com nome, data de preparo e validade. Portanto, a reposição diária não deve ser apresentada no trabalho como dispensa desses cuidados. A referência não comprova como a unidade executa a verificação; isso ainda precisa ser levantado.

### 2.9.2 Estoque de produtos prontos — definição concluída

Em **01/11/2026**, o grupo confirmou nesta conversa o controle por **produto pronto para venda**, em unidades inteiras, e a **baixa quando o pedido quitado é liberado para preparo**. O grupo também confirmou as regras de recebimento, saldo não negativo, perdas/ajustes com motivo, estoque mínimo e retorno somente de produtos aptos para revenda. Essas práticas são registradas como informações da unidade confirmadas pelo grupo; não houve nova visita ou acesso aos registros internos nesta revisão.

- Recebimentos acrescentam unidades ao saldo; perdas e ajustes negativos as retiram. Cada movimento registra produto, quantidade, data/hora, responsável pelo lançamento e motivo.
- A liberação exige quitação exata e saldo suficiente de todos os produtos. A baixa é integral e ocorre uma única vez por item, na mesma transação da liberação. Se faltar qualquer produto, toda a operação é revertida.
- Cancelar antes da baixa não altera estoque. Depois da baixa, o cancelamento e o estorno financeiro não repõem unidades automaticamente. O retorno depende de conferência e confirmação de aptidão para revenda.
- Saldo zero indica indisponibilidade no sistema proposto; saldo menor ou igual ao mínimo indica necessidade de reposição. A publicação nos canais externos depende de integração que não faz parte deste banco.

**Representação autorizada:** ESTOQUE e MOVIMENTACAO_ESTOQUE aparecem **somente a partir do modelo lógico**, com os principais atributos, PKs/FKs, dicionário e implementação SQL. O DER conceitual e seus arquivos continuam com seis entidades; não são acrescentados estoque, movimentações ou seus atributos ao desenho conceitual. Essa diferença de abrangência entre as camadas é uma decisão explícita do grupo.

A implementação utiliza saldo materializado conciliado com um histórico imutável, referências únicas de operação e bloqueios transacionais. Como escolha técnica desta versão, cada retorno é integral por item, uma única vez, mediante confirmação explícita de revenda. Retorno parcial, reservas, ingredientes, receitas, lotes, validade e concessão de cortesias não são funcionalidades desta extensão. Os valores reais de estoque mínimo e os dados das movimentações não foram disponibilizados; os números da carga continuam fictícios.

### 2.9.3 Campanhas de parceria e benefício do banco CITI

Segundo informação do grupo em 28/10/2026, a unidade realiza campanhas quase todos os meses, conforme as parcerias fechadas com grandes empresas. Isso não estabelece uma periodicidade mensal obrigatória nem confirma as condições de todas as campanhas.

O exemplo relatado é o seguinte:

- **Público:** funcionários do banco CITI.
- **Condição de compra:** gasto acima de R$ 39,00. O relato indica valor estritamente maior que R$ 39,00; não foi informado que uma compra de exatamente R$ 39,00 seja elegível.
- **Benefício:** uma bebida na próxima visita à loja.
- **Comprovante:** apresentação do cupom fiscal da compra que gerou o benefício.

Ainda precisam ser confirmados a vigência da campanha, a forma de comprovar vínculo com o CITI, quais bebidas participam, o prazo de resgate, o critério do valor elegível, os canais de compra aceitos, a possibilidade de acumular benefícios e a forma de impedir reutilização do mesmo cupom.

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
4. A definição de estoque foi concluída na Seção 2.9.2. Obter saldos reais, valores mínimos e identificação dos responsáveis para implantação; confirmar separadamente validade e sobras. Contas a pagar e valores históricos de perdas continuam sem acesso. O banco já permite registrar perdas futuras, sem inventar ocorrências reais.
5. Detalhar limpeza e segurança: empresa responsável, atividades, postos, frequência, horários e informações acompanhadas pela unidade.
6. Complementar o registro informativo da campanha CITI e de outras parcerias quando forem fornecidos vigência, bebidas elegíveis e demais condições; manter o desconhecido como pendente, sem ampliar RF24 para concessão ou resgate. Verificar separadamente se existem programas do aplicativo.
7. Conferir produção, qualidade, despesas, divulgação e eventos; justificar com a resposta real cada exclusão. Sobre fechamento, a frequência diária e a execução exclusiva por gerentes já foram confirmadas na entrevista de 08/11/2026. Detalhar somente abertura de caixa, horário de corte, conciliação e eventuais estornos/reaberturas após o fechamento; para cancelamentos, complementar as pendências específicas da Seção 2.7.
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
| RF16 | O sistema deve permitir consultar e consolidar vendas por dia e por mês, relacionando `data_hora`, `origem_pedido`, `valor_total`, produtos vendidos e os valores e situações dos pagamentos, sem duplicar o total de pedidos que possuam vários produtos ou pagamentos. As consultas apoiam o fechamento diário confirmado na Seção 2.8; executá-lo é uma operação distinta, conforme RF31. |
| RF17 | O sistema deve calcular o valor pago pela soma de `valor_pagamento` dos registros Aprovados vinculados ao cupom do pedido e compará-lo com `valor_total`, identificando ausência de pagamento, pagamento parcial, quitação ou divergência. |
| RF18 | Com base no procedimento confirmado na entrevista de 08/11/2026, o sistema deve representar o cancelamento do pedido por CANCELADO em `PEDIDO.status_preparo` e a devolução confirmada por Estornado em `PAGAMENTO.status_pagamento`, preservando os identificadores, vínculos e dados históricos. O relato também confirma cancelamento da nota, estorno imediato pelo cartão e balanceamento automático no sistema existente; o registro da situação fiscal e as integrações externas ainda dependem de implementação própria. |
| RF19 | O sistema deve permitir registrar `nome_comanda` independentemente da existência de `id_cliente`. Quando o nome não for informado, a identificação e a chamada devem utilizar `id_pedido`. |
| RF20 | O sistema deve gerar exatamente um CUPOM_FISCAL para cada pedido, registrando `id_cupom_fiscal`, `id_pedido`, `numero` e `data_hora_emissao`, com identificação e numeração únicas conforme o dicionário. |
| RF21 | O sistema deve permitir localizar um pedido por `id_pedido` e atualizar `status_preparo` para EM_PREPARO, PRONTO ou ENTREGUE conforme o andamento do atendimento descrito na Seção 2.6 e na RN22. A passagem de RECEBIDO para EM_PREPARO exige a quitação calculada por RF17; pedidos cancelados não podem prosseguir para preparo ou entrega. O cancelamento segue RF18, sem ser tratado como atualização comum do preparo. |
| RF22 | o sistema deve registrar os eventos previstos na Seção 5 do dicionário HTML, incluindo consultas, exportações, inclusões e alterações de cadastros, pedidos e pagamentos, mudanças de preço, cancelamentos, estornos, autenticação, mudanças de permissões e tentativas sem autorização. Cada evento deve conter `id_log` único, `data_hora_evento`, `operacao`, `entidade_alvo` quando aplicável, `referencia_registro` quando houver registro específico, `resultado` (SUCESSO, NEGADO ou FALHA), `identificacao_ator` e `perfil_utilizado` quando disponíveis e `motivo` quando aplicável. O resultado da operação não substitui `PAGAMENTO.status_pagamento`. |
| RF23 | **Controle de acesso — proposta com atribuição de fechamento confirmada:** antes de executar uma operação, o sistema deve verificar o perfil da conta, serviço ou sessão, a operação solicitada e o recurso ou registro envolvido, autorizando ou negando a ação conforme a matriz da Seção 6.2 do dicionário HTML. A verificação deve abranger consultas, cadastros, alterações, cancelamentos, estornos, fechamento diário, exportações e acesso aos logs. Operações sem autorização expressa devem ser negadas; tentativas negadas devem ser registradas conforme RF22. A execução do fechamento é exclusiva da Gerência, conforme RF31/RN33; as demais atribuições dos perfis e os acessos técnicos de TOTEM e DELIVERY dependem de confirmação com a unidade. |
| RF24 | O sistema deve permitir registrar e consultar informações de campanhas de parceria com identificação da campanha, empresa parceira, público-alvo, condição de compra, benefício, comprovante exigido, vigência quando conhecida e observações sobre condições pendentes. Para a campanha CITI, o registro deve preservar as informações relatadas na Seção 2.9.3: funcionários do banco, compra acima de R$ 39,00, uma bebida na próxima visita e apresentação do cupom fiscal. O escopo é informativo, sem registrar concessões ou resgates individuais nem validar automaticamente o direito ao benefício. |
| RF25 | O sistema deve permitir registrar e consultar manualmente uma escala, com identificação do registro, pessoa identificada por código e nome, setor, vínculo, período e indicação dos dias de trabalho e folga. O exemplo da Seção 2.10 utiliza uma semana-modelo sem datas reais, com 15 pessoas e nomes fictícios; para uso operacional, esses dados devem corresponder às informações fornecidas pela unidade ou pelas prestadoras. O requisito abrange registro e consulta, sem geração automática de escala ou controle de presença. |
| RF26 | O sistema deve manter saldo e estoque mínimo por produto pronto, em unidades inteiras, e registrar recebimentos, perdas e ajustes com quantidade, data/hora, motivo, responsável e referência única. |
| RF27 | Quando um pedido quitado for liberado para preparo, o sistema deve baixar todos os itens uma única vez, impedindo saldo negativo e revertendo integralmente a liberação se qualquer baixa falhar. |
| RF28 | O cancelamento deve preservar as baixas anteriores e não repor saldo automaticamente. O retorno só deve ocorrer após confirmação de aptidão para revenda, vinculado ao item baixado e sem duplicação. |
| RF29 | O sistema deve consultar saldos, indisponibilidade e produtos no limite mínimo e consolidar movimentações por período, sem confundir consumo físico com faturamento. |
| RF30 | O sistema deve preservar o histórico de movimentações e permitir conciliar o saldo materializado com entradas, saídas e retornos. Correções devem gerar novos movimentos com motivo. |
| RF31 | O sistema deve permitir realizar o fechamento das vendas ao final de cada dia exclusivamente por um gerente autorizado, conforme a entrevista de 08/11/2026 e RN33. A operação deve distinguir a consulta de resultados da efetivação do fechamento. Seu registro próprio e a verificação de acesso ainda dependem de modelagem e implementação. |

RF24 e RF25 definem os registros solicitados pelo grupo. Sua inclusão como requisitos não significa que esses registros já estejam implementados ou representados nas seis entidades do modelo atual. A estrutura desses dados ainda deverá ser alinhada ao dicionário e ao DER, preservando o caráter fictício do exemplo e as condições desconhecidas das campanhas como pendências.

## 3.2 Requisitos Não Funcionais

| Código | Requisito detalhado e verificação prevista |
|---|---|
| RNF01 | **Usabilidade:** os campos de cadastro, pedido e pagamento devem apresentar rótulos correspondentes ao dicionário. Mensagens de validação devem identificar o campo e o problema, como ausência de `nome`, `quantidade` inválida ou falta de `totem` na origem TOTEM. O `valor_total` deve ser apresentado como calculado. |
| RNF02 | **Integridade:** os vínculos entre `id_cliente`, `id_funcionario`, `id_pedido`, `id_produto`, `id_cupom_fiscal` e `id_pagamento` devem permanecer consistentes. Devem ser verificadas unicidade, obrigatoriedade, domínios e condições definidas nas regras de negócio, incluindo quantidades, preços, pagamentos e quitação. |
| RNF03 | **Segurança:** a consulta e a alteração de dados pessoais, cadastrais e financeiros — como `nome`, `cpf_cnpj`, preços e dados dos pagamentos — devem respeitar as permissões por operação previstas em RF23. O fechamento diário deve ser restrito a gerentes autorizados, conforme RF31/RN33. A auditoria dessas operações deve seguir RF22, evitando dados pessoais desnecessários e impedindo que perfis operacionais editem ou apaguem logs. As demais atribuições dos perfis nas Seções 6.1 e 6.2 do dicionário HTML, incluindo os acessos técnicos de TOTEM e DELIVERY, ainda precisam ser confirmadas. |
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
| Realizar o fechamento diário exclusivamente por gerentes, distinguindo-o da consulta de relatórios. | RF16, RF23, RF31, RN33 e RNF03. | Fluxo da [Seção 2](./index.html) e matriz da [Seção 6.2](./index.html#permissoes-retencao). |

RF22 e RF23 formalizam propostas já documentadas no HTML; autenticação, perfis e auditoria ainda não estão implementados. A atribuição do fechamento exclusivamente aos gerentes foi confirmada na entrevista de 08/11/2026 e consta de RF31/RN33; as demais permissões continuam propostas a validar. Os campos de log e o registro de fechamento não integram as nove tabelas e 44 colunas do modelo lógico atual e ainda dependem de modelagem própria.

No balcão, a identificação de uma sessão compartilhada não comprova qual funcionário executou pessoalmente uma ação e não torna `PEDIDO.id_funcionario` obrigatório. O controle de acesso deve preservar RF06 e RN08. Consultas ou exportações que não estejam expressamente autorizadas na matriz devem ser negadas até sua definição.

O estoque foi definido na Seção 2.9.2 e nos requisitos RF26–RF30, com representação apenas lógica/física. Reservas e concessão de cortesias não integram essa extensão.

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
| RN17 | PAGAMENTO deve registrar obrigatoriamente `forma_pagamento`, `valor_pagamento`, `status_pagamento` e `data_hora_pagamento`. A forma admite PIX, Crédito, Débito ou Dinheiro; o valor deve ser maior que zero. A situação admite Aprovado, Recusado ou Estornado, este último após devolução confirmada. | RF09, RF10, RF18 |
| RN18 | A divisão da conta gera registros de pagamento separados, cada um com sua forma e seu valor, mantendo todos vinculados ao mesmo cupom e, por ele, ao mesmo pedido. | RF09, RF10 |
| RN19 | O valor pago corresponde exclusivamente à soma de `valor_pagamento` dos registros com `status_pagamento = Aprovado`. Na ausência de aprovados, o resultado é zero. Recusados e Estornados não compõem essa soma. | RF09, RF17 |
| RN20 | Um pedido somente é considerado quitado quando o valor pago corresponde exatamente a `valor_total`. Valor inferior indica pendência; valor superior indica divergência a conciliar. | RF17 |
| RN21 | Uma tentativa recusada permanece no histórico e permite outra tentativa com novo `id_pagamento`, vinculada ao mesmo cupom. A recusa não cancela automaticamente o pedido nem desfaz pagamentos anteriormente aprovados. | RF09, RF10, RF17 |
| RN22 | `status_preparo` representa RECEBIDO, EM_PREPARO, PRONTO ou ENTREGUE. A liberação para preparo exige quitação. A entrega é identificada pelo `nome_comanda` ou pelo número `id_pedido`. | RF05, RF17, RF19, RF21 |
| RN23 | O cancelamento da nota e do pedido foi confirmado na entrevista de 08/11/2026. No modelo, CANCELADO em `status_preparo` impede a continuidade do atendimento, mesmo com pagamento integral, e preserva o histórico. O registro específico do cancelamento fiscal, os estágios permitidos e os responsáveis por autorizar/operar o cancelamento ainda precisam de detalhamento. | RF18 |
| RN24 | O relato confirma estorno imediato pelo cartão e balanceamento automático no sistema existente. No modelo, um pagamento aprovado passa para Estornado após devolução confirmada; o estorno integral por registro é uma escolha técnica desta versão. Sem confirmação, permanece Aprovado e gera uma exceção de devolução pendente. Recusados não exigem estorno. Pedido, cupom e pagamentos são preservados. Outras formas de devolução e eventos após o fechamento permanecem a detalhar. | RF09, RF18 |
| RN25 | Cada produto pronto possui um registro de ESTOQUE no modelo lógico, com saldo inicial zero, saldo e mínimo inteiros não negativos. | RF26 |
| RN26 | Cada movimento registra quantidade positiva, produto existente, data/hora, responsável, motivo não vazio e referência única; entradas e ajustes positivos aumentam o saldo, perdas e ajustes negativos o reduzem. | RF26 |
| RN27 | Baixa por VENDA corresponde integralmente à quantidade do item, ocorre uma única vez e integra a liberação de pedido exatamente quitado para preparo. Pedidos sem saldo suficiente não são liberados. | RF27 |
| RN28 | Cancelamento e estorno não repõem saldo automaticamente. RETORNO exige pedido cancelado, baixa anterior e confirmação de revenda; nesta implementação há no máximo um retorno integral por item. | RF28 |
| RN29 | Movimentações não podem ser alteradas ou excluídas. Ajustes exigem novo lançamento rastreável. O responsável pela movimentação não torna obrigatório o funcionário no registro da venda de balcão. | RF26, RF30 |
| RN30 | Saldo zero indica indisponibilidade local; saldo menor ou igual ao estoque mínimo indica reposição. Não se presume sincronização automática dos canais externos. | RF29 |
| RN31 | A liberação e todas as baixas formam uma transação: falhas revertem tudo; operações concorrentes não podem consumir as mesmas unidades além do saldo. | RF27 |
| RN32 | O saldo materializado deve corresponder ao somatório de entradas e retornos menos saídas; a composição de pedidos com baixa deve ser preservada. | RF27, RF30 |
| RN33 | O fechamento de vendas ocorre ao final de cada dia e somente pode ser realizado por gerentes, conforme a entrevista de 08/11/2026. Consultar relatórios não concede permissão para efetivar o fechamento. Horário exato de corte e regras de reabertura ou estorno após fechamento ainda não foram informados. | RF16, RF23, RF31 |

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

**Tratamento baseado no procedimento confirmado:** a entrevista de 08/11/2026 confirma cancelamento da nota e do pedido, estorno imediato pelo cartão e balanceamento automático no sistema existente. No modelo acadêmico, registrar **CANCELADO** em `status_preparo` e **Estornado** em cada pagamento cuja devolução foi confirmada, preservando pedido, cupom e pagamentos. Cada registro é estornado integralmente como escolha técnica desta versão. Sem confirmação, o pagamento permanece **Aprovado** e caracteriza uma exceção de devolução pendente, que deve ser conferida. Um pagamento recusado não exige estorno. O registro da situação fiscal e a execução externa da devolução ainda não estão implementados; as pendências específicas estão na Seção 2.7.

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
| status_preparo | Situação do pedido durante a preparação e entrega | Obrigatório: RECEBIDO, EM_PREPARO, PRONTO, ENTREGUE ou CANCELADO; este último representa o cancelamento confirmado no levantamento (Seção 4.1.1) |

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
| CANCELADO | Registra o cancelamento e impede a continuidade do atendimento, conforme a Seção 4.1.1. |

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
| status_pagamento | Situação do pagamento | Obrigatório: Aprovado, Recusado ou Estornado; este último registra devolução confirmada. O recorte usa estorno integral por registro (Seção 4.1.1). |
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

**Software utilizado na criação do DER:** brModelo 3, com arquivo editável no formato `.brM3`.

### Notação do modelo conceitual

O DER deve seguir a notação do **brModelo**, conforme a orientação da atividade, aplicável a todos os grupos dos Casos A e B.

| Elemento | Representação |
|---|---|
| Entidade | Retângulo. |
| Relacionamento | Losango. |
| Cardinalidade | Par `(mín, máx)` nos dois lados de cada relacionamento, como `(0, 1)`, `(1, n)` e `(0, n)`. |
| Autorrelacionamento | Losango ligado duas vezes à mesma entidade, com cardinalidade em cada ligação. |
| Atributo identificador | Círculo preenchido ligado à entidade; se os atributos forem listados dentro do retângulo, o identificador deve estar sublinhado. |
| Identificador composto | Mais de um círculo preenchido na mesma entidade ou todos os atributos que compõem o identificador sublinhados na lista interna. |
| Atributo comum | Círculo vazio ligado à entidade ou ao relacionamento correspondente. |
| Atributo multivalorado | Círculo vazio acompanhado da cardinalidade do atributo, como `(1, n)`. |
| Atributo composto | Pode apresentar subatributos ligados ao atributo principal; essa representação gráfica é opcional. |
| Generalização/especialização | Triângulo ligando a entidade genérica às especializadas; a indicação de totalidade e disjunção é opcional. |
| Entidade associativa | Retângulo envolvendo o losango do relacionamento, permitindo atributos próprios e relacionamentos com outras entidades. |

Os atributos das **entidades** podem ser desenhados como círculos ligados ou listados dentro do retângulo, com os identificadores sublinhados nessa segunda opção. Os atributos de **relacionamentos e entidades associativas** devem ser exclusivamente externos, ligados ao losango ou à entidade associativa, sem listagem dentro de retângulos. No modelo atual, `quantidade` e `preco_unitario` estão ligados ao losango CONTÉM.

**Não representar chaves estrangeiras no DER conceitual.** Os vínculos são expressos pelos relacionamentos; as referências de FK documentadas para implementação pertencem ao modelo lógico.

![DER da We Coffee com pedido, produto, cupom fiscal e pagamento](<./WECOFFE/Modelo_Conceitual_WeCoffee_BRModelo.png>)

O DER, o arquivo editável brModelo e as exportações PNG, JPG e PDF apresentam **seis entidades, cinco relacionamentos e 26 atributos conceituais**, sem FORNECEDOR. O dicionário conceitual da Seção 5 desta entrega documenta **30 atributos**: 26 conceituais e quatro referências de FK para o modelo lógico. O HTML consolidado documenta separadamente as **nove tabelas e 44 colunas físicas** da Entrega 2, incluindo as extensões exclusivamente lógicas. Ele trata `PEDIDO.id_funcionario` como opcional, inclusive nas vendas de balcão. O registro manual de escala solicitado em RF25, exemplificado na Seção 2.10, ainda não está representado no DER; sua representação permanece pendente de modelagem. Nomes, códigos e dias do exemplo continuam fictícios.

O DER conceitual não representa abastecimento ou estoque por decisão do grupo. O controle quantitativo foi definido em 01/11/2026 e é representado exclusivamente a partir do modelo lógico, conforme a Seção 2.9.2. O registro informativo de campanhas previsto em RF24 ainda não possui representação específica. Concessão e resgate de benefícios não integram RF24 nesta etapa. Os registros de campanha e escala foram incluídos nos requisitos por solicitação do grupo, mas ainda precisam ser representados no dicionário e no DER; as contagens acima descrevem os artefatos atuais.

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

## 7.3 Modelo Lógico

O modelo lógico detalha a organização dos dados em tabelas, com seus campos, tipos, chaves primárias e chaves estrangeiras. Na conversão do modelo conceitual, o relacionamento N:M **CONTÉM**, entre PEDIDO e PRODUTO, foi transformado na tabela associativa **ITEM_PEDIDO**, que registra a quantidade e o preço unitário praticado na venda.

![Modelo lógico da We Coffee no brModelo](./WECOFFE/modelagem/Modelo_Logico_WeCoffee_brModelo.png)

A modificação também incluiu **ESTOQUE**, para registrar o saldo disponível e o estoque mínimo de cada produto pronto, e **MOVIMENTACAO_ESTOQUE**, para manter o histórico de entradas, vendas, perdas, ajustes e retornos, com identificação do funcionário responsável. Com essa ampliação, o modelo lógico passou a conter **nove tabelas e 44 colunas**.

O estoque apareceu somente nesta etapa porque, no levantamento inicial, suas regras ainda estavam pendentes de definição. Em **01/11/2026**, o grupo confirmou o controle por produto pronto, a baixa na liberação do pedido para preparo e as regras de recebimento, perdas, ajustes e retorno. A partir dessas definições, foi possível estruturar as duas tabelas e implementar o controle no SQL. Por decisão de escopo do grupo, o modelo conceitual da entrega original foi preservado com seis entidades, e essa ampliação foi incorporada ao modelo lógico e à implementação física, conforme a Seção 2.9.2.

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

## 9.5 Controle de estoque lógico e validação MySQL — 01/11/2026

| Item | Registro desta revisão |
|---|---|
| Ferramenta e finalidade | Codex, para implementar estoque no SQL e no modelo lógico, atualizar documentação e testar saldo, idempotência e concorrência. |
| Confirmação do grupo | Controle por produto pronto, baixa na liberação para preparo e regras complementares aceitas como práticas da unidade informadas pelo grupo nesta conversa. |
| Restrição expressa | Estoque e movimentações somente a partir do modelo lógico; preservar o DER conceitual e seus arquivos. |
| Resultado | RF26–RF30, RN25–RN32, nove tabelas lógicas, saldo e movimentos, rotinas/triggers, G08–G09, A12–A16, diagrama e dicionário atualizados. |
| Verificação | Script executado do zero no MySQL 8.0.46; 54 verificações gerais/de estoque e quatro de atomicidade/concorrência, com evidências em docs. Diagrama lógico conferido visualmente. |
| Limites | Não houve nova visita nem acesso aos registros internos. Pessoas, saldos, mínimos e movimentos da carga são fictícios. Lotes, validade, reservas e publicação nos canais externos não foram implementados. |

## 9.6 Confirmações da entrevista com o auxiliar geral — 09/11/2026

| Item | Registro desta revisão |
|---|---|
| Ferramenta e finalidade | Codex, para propagar as confirmações recebidas aos processos, requisitos, regras de negócio, dicionário HTML e comentários SQL. |
| Fonte humana | Relato do grupo sobre entrevista com o auxiliar geral Leandro Viana em 08/11/2026, informado nesta conversa em 09/11/2026. O assistente não realizou a entrevista nem verificou operações no sistema da unidade. |
| Informações confirmadas | Fechamento ao final de cada dia, executado apenas pelos gerentes; cancelamento da nota e do pedido; estorno na hora pelo cartão e balanceamento automático pelo sistema existente. |
| Resultado | Atualizados RF16, RF18, RF21, RF23, RNF03, RN17, RN23 e RN24; acrescentados RF31 e RN33. Alinhadas as descrições dos estados, as permissões de fechamento e os limites analíticos. |
| Limites | Permanecem a detalhar corte exato, reabertura, estornos após fechamento, permissões de cancelamento/estorno e devoluções por outros meios. Registros fiscais de cancelamento, eventos de estorno, fechamento histórico, autenticação e integrações externas não foram implementados nesta revisão. |

---
- **Participação (10%):** envolvimento nas discussões técnicas e nas decisões do grupo.
- **Comprometimento (8%):** cumprimento de prazos e responsabilidades assumidas.
- **Colaboração (4%):** respeito às contribuições dos colegas, cooperação na construção do projeto e colaboração equilibrada no histórico de commits do repositório GitHub.
- **Autonomia (7%):** busca independente de soluções e proposta de melhorias.

----

# Entrega 2 — Proposta de Modelo Lógico e Arquitetura Analítica

Esta entrega apresenta a conversão relacional das seis entidades do modelo conceitual vigente. O resultado contém **nove tabelas**: as seis entidades convertidas, ITEM_PEDIDO (CONTÉM) e as extensões lógicas ESTOQUE e MOVIMENTACAO_ESTOQUE. Trata-se de uma proposta lógica: o script completo está em `WECOFFE/docs/script.sql`, validado em instância temporária do MySQL, sem implantação no ambiente operacional. As regras RNxx citadas correspondem à Seção 4 da Entrega 1. Campanhas e escala (RF24 e RF25) continuam pendentes de modelagem. O estoque foi incluído apenas nas camadas lógica e física, conforme a decisão do grupo.

## 1.2 Conversão do Modelo Conceitual para o Modelo Lógico

### Entidades e atributos convertidos

Cada entidade origina uma tabela e cada atributo armazenado origina uma coluna. Os identificadores próprios são preservados. As FKs abaixo concretizam os relacionamentos, sem acrescentá-las ao DER conceitual.

| Origem conceitual | Tabela e colunas propostas |
|---|---|
| CLIENTE | `CLIENTE(id_cliente, nome, cpf_cnpj)` |
| FUNCIONARIO | `FUNCIONARIO(id_funcionario, nome, cargo)` |
| PRODUTO | `PRODUTO(id_produto, nome, preco)` |
| PEDIDO | `PEDIDO(id_pedido, id_cliente, id_funcionario, totem, nome_comanda, data_hora, origem_pedido, status_preparo)` |
| CUPOM_FISCAL | `CUPOM_FISCAL(id_cupom_fiscal, id_pedido, numero, data_hora_emissao)` |
| PAGAMENTO | `PAGAMENTO(id_pagamento, id_cupom_fiscal, forma_pagamento, valor_pagamento, status_pagamento, data_hora_pagamento)` |
| Relacionamento CONTÉM e seus atributos | `ITEM_PEDIDO(id_pedido, id_produto, quantidade, preco_unitario)` |
| Extensão exclusivamente lógica | `ESTOQUE(id_produto, quantidade_disponivel, estoque_minimo, data_atualizacao)` |
| Extensão exclusivamente lógica | `MOVIMENTACAO_ESTOQUE(id_movimentacao, id_produto, id_pedido, id_funcionario, tipo, quantidade, data_hora, motivo, referencia)` |

Propõem-se identificadores inteiros, textos em `VARCHAR`, datas em `DATETIME`, quantidade em inteiro e valores monetários em `DECIMAL`, com precisão `DECIMAL(12,2)` definida no DDL. Valores monetários não devem utilizar ponto flutuante. CPF/CNPJ e número fiscal são textos para preservar zeros e formatação significativa; o documento deve ser padronizado antes da verificação de unicidade. Os tamanhos dos textos estão definidos no diagrama, no dicionário lógico e no DDL.

`valor_total` não vira coluna física: uma consulta ou view calcula `SUM(quantidade * preco_unitario)` por pedido (RN13). Valor pago e situação financeira também são derivados. `totem` permanece uma coluna condicional de PEDIDO, sem FK. `nome_comanda` preserva a identificação usada naquela compra, independentemente de alterações no nome do cliente (RN10).

ESTOQUE e MOVIMENTACAO_ESTOQUE não correspondem a novas entidades desenhadas no DER conceitual: são extensões introduzidas nesta camada por orientação explícita do grupo.

### Relacionamentos e cardinalidades

| Relacionamento | Conversão lógica e participação |
|---|---|
| CLIENTE 1:N PEDIDO | `PEDIDO.id_cliente` é FK anulável. Um cliente pode ter zero ou muitos pedidos; um pedido tem zero ou um cliente cadastrado. |
| FUNCIONARIO 1:N PEDIDO | `PEDIDO.id_funcionario` é FK anulável, inclusive no balcão. Um funcionário pode ter zero ou muitos pedidos associados; cada pedido possui no máximo um funcionário associado. |
| PEDIDO N:N PRODUTO | ITEM_PEDIDO decompõe a relação em duas relações 1:N. Cada item pertence a um pedido e a um produto existentes. Um pedido deve ter pelo menos um item; um produto pode nunca ter sido vendido. |
| PEDIDO 1:1 CUPOM_FISCAL | `CUPOM_FISCAL.id_pedido` recebe FK, `NOT NULL` e `UNIQUE`, garantindo um pedido por cupom e no máximo um cupom por pedido. A existência de um cupom para **todo** pedido exige controle transacional adicional. |
| CUPOM_FISCAL 1:N PAGAMENTO | `PAGAMENTO.id_cupom_fiscal` recebe FK e `NOT NULL`. Cada pagamento pertence a um cupom; a existência de pelo menos uma tentativa por cupom também exige controle transacional. |

A PK de ITEM_PEDIDO é `(id_pedido, id_produto)`: cada produto aparece uma vez por pedido, com as unidades consolidadas em `quantidade`. Isso pressupõe um único preço praticado por produto no mesmo pedido. Caso sejam necessários preços diferentes para o mesmo produto no mesmo pedido, será necessário rever a chave para identificar linhas individuais; essa necessidade não consta do levantamento atual.

PRODUTO e ESTOQUE têm relação 1:1, com `ESTOQUE.id_produto` como PK/FK. ESTOQUE possui zero ou muitos movimentos; cada movimento exige um estoque e um funcionário responsável. A FK composta opcional `(id_pedido, id_produto)` de MOVIMENTACAO_ESTOQUE referencia ITEM_PEDIDO: recebimentos, perdas e ajustes não têm pedido; vendas e retornos exigem o item correspondente.

Não há generalização/especialização no DER vigente. Portanto, não se aplica estratégia de tabela única, uma tabela por entidade ou apenas tabelas especializadas. TOTEM, BALCÃO e DELIVERY são valores de `origem_pedido`, sem hierarquia de subtipos.

## 1.3 Definição de Chaves Primárias e Estrangeiras

| Tabela | Chave primária (PK) | Chaves estrangeiras (FK) | Outras chaves e opcionalidade |
|---|---|---|---|
| CLIENTE | `id_cliente` | Nenhuma | `cpf_cnpj` único quando informado; admite NULL. |
| FUNCIONARIO | `id_funcionario` | Nenhuma | Nome e cargo não são chaves. |
| PRODUTO | `id_produto` | Nenhuma | Nome não é necessariamente único. |
| PEDIDO | `id_pedido` | `id_cliente → CLIENTE.id_cliente`; `id_funcionario → FUNCIONARIO.id_funcionario` | Ambas as FKs admitem NULL. |
| ITEM_PEDIDO | `(id_pedido, id_produto)` | `id_pedido → PEDIDO.id_pedido`; `id_produto → PRODUTO.id_produto` | Ambas obrigatórias e integrantes da PK. |
| CUPOM_FISCAL | `id_cupom_fiscal` | `id_pedido → PEDIDO.id_pedido` | FK obrigatória e única; `numero` obrigatório e único na unidade. |
| PAGAMENTO | `id_pagamento` | `id_cupom_fiscal → CUPOM_FISCAL.id_cupom_fiscal` | FK obrigatória; várias tentativas por cupom. |
| ESTOQUE | `id_produto` | `id_produto → PRODUTO.id_produto` | PK e FK obrigatória. |
| MOVIMENTACAO_ESTOQUE | `id_movimentacao` | `id_produto → ESTOQUE.id_produto`; `id_funcionario → FUNCIONARIO.id_funcionario`; `(id_pedido, id_produto) → ITEM_PEDIDO(id_pedido, id_produto)` | `id_pedido` opcional; `referencia UNIQUE`; combinação `(id_pedido,id_produto,tipo)` única. |

## 1.4 Processo de Normalização (1FN, 2FN e 3FN)

A análise considera as dependências funcionais documentadas e o recorte de uma unidade. Não pressupõe a existência de uma planilha desnormalizada anterior.

| Forma normal | Aplicação ao modelo | Necessidade no caso |
|---|---|---|
| 1FN | Cada coluna guarda um valor por linha. Produtos são linhas em ITEM_PEDIDO; tentativas e parcelas são linhas em PAGAMENTO. Não existem listas de produtos ou colunas como `produto1`, `produto2`, `pagamento1`. | Permite qualquer quantidade de produtos e tentativas sem alterar a estrutura; possibilita somar quantidades e valores corretamente. |
| 2FN | Em ITEM_PEDIDO, `(id_pedido, id_produto) → quantidade, preco_unitario`. Nome e preço atual do produto ficam em PRODUTO; data e origem ficam em PEDIDO. Nenhum atributo não chave do item depende apenas de parte da PK. As outras tabelas têm PK simples e não apresentam dependências parciais segundo as regras levantadas. | Evita repetir o cadastro do produto em cada item e os dados do pedido em todas as suas linhas, reduzindo anomalias de atualização. |
| 3FN | Nome/documento do cliente ficam em CLIENTE; nome/cargo do funcionário em FUNCIONARIO; dados fiscais em CUPOM_FISCAL. PAGAMENTO não repete `id_pedido`, pois o pedido é obtido por `id_cupom_fiscal`. Não foram identificadas dependências transitivas entre atributos não chave dentro das tabelas propostas. | Evita divergência entre cadastros e transações e impede que um pagamento aponte simultaneamente para um cupom e para um pedido incompatíveis. |

`preco_unitario` depende da associação entre pedido e produto, e não apenas de `id_produto`: representa o preço histórico da venda, enquanto `PRODUTO.preco` representa o preço atual. Por isso, ambos são necessários e não constituem uma dependência parcial. Da mesma forma, `nome_comanda` é um registro histórico do pedido, não uma cópia permanentemente sincronizada de CLIENTE.nome.

O total do pedido não é armazenado para evitar inconsistência com os itens. A normalização foi aplicada sem criar tabelas de cargo, origem ou situação: no levantamento atual, esses valores não possuem atributos próprios que exijam entidades independentes. A conclusão de 3FN deve ser revista se novas dependências de negócio forem identificadas.

Na extensão de estoque, as linhas de movimentação eliminam grupos repetitivos (1FN); os dados do produto e do responsável permanecem nos cadastros, sem dependências parciais ou transitivas adicionadas (2FN/3FN). ESTOQUE guarda mínimo e saldo por produto; MOVIMENTACAO_ESTOQUE guarda os fatos de cada movimento. O saldo é uma materialização controlada do livro de movimentos, mantida por trigger em atualização atômica e conciliada por A12. Essa redundância entre tabelas é deliberada para evitar consumo concorrente acima do disponível, sem duplicar nomes ou dados cadastrais.

## 1.5 Justificativas Técnicas das Decisões

As seis entidades originais usam identificadores próprios, obrigatórios e únicos (RN01), evitando depender de nomes mutáveis, do documento opcional do cliente ou da numeração fiscal. `id_pagamento` distingue tentativas sucessivas para o mesmo cupom, inclusive recusadas (RN21). A PK composta de ITEM_PEDIDO identifica a participação do produto no pedido e impede duplicação dessa associação (RN11–RN12).

As FKs preservam a existência dos registros referenciados. As de cliente e funcionário são opcionais para permitir atendimento sem cadastro e sem identificação individual no balcão (RN03, RN06, RN08–RN09). A FK única de CUPOM_FISCAL implementa o limite 1:1 (RN14); a FK de PAGAMENTO permite divisão da conta e novas tentativas (RN16, RN18, RN21). As duas FKs de ITEM_PEDIDO resolvem o N:N com quantidade e preço histórico (RN11–RN12).

ESTOQUE usa o identificador do produto como PK/FK para garantir um único saldo por produto. MOVIMENTACAO_ESTOQUE usa identificador próprio para distinguir lançamentos e referência de operação única para impedir repetição. Sua FK composta garante que a venda ou o retorno pertença a um produto realmente presente no pedido; a FK de funcionário identifica quem registrou o movimento. Saldo materializado, livro imutável e bloqueios por produto permitem conferir o histórico e impedir consumo concorrente acima do disponível (RN25–RN32).

| Restrição ou decisão | Implementação proposta e justificativa | Regra |
|---|---|---|
| Identificadores | `PRIMARY KEY` nas nove tabelas; oito simples e uma composta, incluindo a PK/FK de ESTOQUE. | RN01, RN11 |
| Cadastro de cliente | `nome NOT NULL`; rejeitar nome vazio; `cpf_cnpj` anulável e `UNIQUE`, com vazio convertido em NULL. | RN02, RN09 |
| Cadastro de funcionário | `nome` e `cargo NOT NULL`, sem texto vazio; FK opcional no pedido. | RN03, RN08 |
| Produto | `nome` e `preco NOT NULL`; nome não vazio e `CHECK (preco > 0)`. | RN04 |
| Pedido e canal | Data, origem e situação obrigatórias; `CHECK` dos três canais e condição: TOTEM exige `totem` não vazio; demais canais exigem NULL. | RN06–RN07 |
| Comanda | Nome opcional; usar `id_pedido` quando ausente, sem criar cliente fictício. | RN09–RN10 |
| Itens | FKs obrigatórias; quantidade inteira com `CHECK (quantidade > 0)`; preço histórico obrigatório. RN12 não define explicitamente seu limite numérico, que deve ser validado antes de acrescentar uma restrição adicional. | RN11–RN12 |
| Total e quitação | Total e valor pago calculados separadamente; igualdade exata em decimal para quitação; ausência de aprovados resulta em zero. | RN13, RN19–RN20 |
| Cupom fiscal | `id_pedido NOT NULL UNIQUE`; número obrigatório, não vazio e único; emissão obrigatória. A unicidade do número vale para a unidade deste recorte. | RN14–RN15 |
| Pagamento | FK, forma, valor, situação e data obrigatórios; `CHECK (valor_pagamento > 0)`; domínios PIX/Crédito/Débito/Dinheiro e Aprovado/Recusado/Estornado. Estornado representa devolução confirmada, apoiada no procedimento relatado na entrevista de 08/11/2026. | RN16–RN18, RN24 |
| Estoque e movimentos | PK/FKs, saldo/mínimo não negativos, quantidade positiva, tipo e vínculo com pedido condicionais, referência única e UNIQUE por item/tipo. Triggers mantêm o saldo e preservam o livro; rotinas validam quitação, baixa e retorno. | RN25–RN32 |
| Preparo e histórico | Domínio RECEBIDO/EM_PREPARO/PRONTO/ENTREGUE/CANCELADO. Transições exigem validação da quitação e bloqueio após cancelamento; estorno depende de devolução confirmada. O cancelamento fiscal relatado ainda não possui situação própria no banco. | RN21–RN24 |
| Fechamento diário | Frequência diária e execução exclusiva por gerentes confirmadas. As consultas apoiam a conferência; registro de fechamento, identificação do gerente e controle de acesso ainda exigem implementação. | RN33 |

`NOT NULL` não impede texto vazio; as validações textuais precisam ser implementadas explicitamente. No MySQL, o `UNIQUE` de documento deve permitir vários NULLs. A versão do SGBD e a efetiva aplicação de `CHECK` devem ser verificadas ao implementar o DDL.

As cardinalidades mínimas — pedido com item e cupom, cupom com tentativa — não são garantidas apenas pelas FKs. Propõe-se um serviço transacional ou rotinas controladas que concluam o registro somente após validar essas condições; transações incompletas devem ser revertidas. A liberação para preparo deve conferir total e pagamentos sob controle de concorrência, impedindo alterações simultâneas que invalidem a quitação. A liberação para preparo está implementada por `sp_liberar_preparo`, com baixa e quitação atômicas. A conclusão cadastral de todo pedido com cupom e tentativa ainda requer serviço transacional próprio; as auditorias A01–A03 verificam essas cardinalidades mínimas.

Propõe-se bloquear exclusões de registros referenciados e preservar o histórico, em vez de propagar exclusões em cascata. Alterações do preço atual não devem reescrever itens antigos. Cupom e pagamento permanecem separados para representar suas responsabilidades e cardinalidades. Índices nas FKs e nas datas de análise devem ser avaliados na implementação. A ampliação para várias unidades exigiria rever a chave fiscal, por exemplo com unidade/série/número, após levantamento próprio.

## 1.6 Proposta de Arquitetura Analítica para BI e IA

O modelo apoia a consolidação mensal das vendas, comparação de canais, identificação dos produtos mais vendidos e acompanhamento de pendências financeiras. Ele não permite calcular lucro ou margem, pois não contém custos, despesas ou taxas de plataforma; agora mede saldo atual, indisponibilidade e unidades de perdas registradas por meio das movimentações de estoque.

### Arquitetura proposta

1. **Camada operacional:** as nove tabelas sustentam o atendimento e preservam preços históricos e tentativas de pagamento.
2. **Extração e preparação:** carga incremental por identificadores e datas, com reconciliação de alterações de situação em pedidos e pagamentos. Como não há `updated_at` ou histórico de eventos, uma carga confiável precisará de CDC, inclusão de controle de alteração ou releitura dos registros sujeitos a mudanças.
3. **Camada analítica:** fato de itens com uma linha por pedido/produto e fato de pagamentos com uma linha por tentativa e fato de movimentos com uma linha por lançamento de estoque; dimensões de data, produto e canal e, quando pertinente, cliente pseudonimizado. Datas de venda, emissão e pagamento devem ter papéis separados. Dimensões históricas exigirão captura adicional de alterações cadastrais.
4. **Camada de consumo:** dashboards de vendas, produtos e pagamentos com filtros por período e canal. Totais de itens e pagamentos devem ser agregados por pedido/cupom antes de combinados para evitar dupla contagem.

### Indicadores e rastreabilidade

Os códigos P1 e P2 abaixo identificam os dois problemas já descritos na caracterização da organização. As consultas G01–G09 estão no [script SQL completo da Seção 3](./WECOFFE/docs/script.sql), com a pergunta e os problemas/KPIs atendidos nos cabeçalhos. Foram executadas com massa fictícia no MySQL 8.0.46.

| Problema ou KPI | Definição e interpretação | Tabelas envolvidas | Consulta no script |
|---|---|---|---|
| P1 — dificuldade de consolidação mensal | Consolidar vendas quitadas por mês da venda e canal; conciliar pendências separadamente. | PEDIDO, ITEM_PEDIDO, CUPOM_FISCAL, PAGAMENTO | G01, G04 |
| P2 — atualização da disponibilidade quando um produto acaba | Identificar saldo zero, reposição e fluxo de consumo; a atualização nos canais externos depende de integração própria. | PRODUTO, ESTOQUE, MOVIMENTACAO_ESTOQUE | G08, G09 |
| K01 — valor e quantidade de vendas quitadas | Soma dos totais e contagem de pedidos não cancelados cujo valor aprovado é exatamente igual ao total. | PEDIDO, ITEM_PEDIDO, CUPOM_FISCAL, PAGAMENTO | G01 |
| K02 — ticket médio por canal | Valor das vendas quitadas dividido pelo número desses pedidos no período e canal. | PEDIDO, ITEM_PEDIDO, CUPOM_FISCAL, PAGAMENTO | G01 |
| K03 — unidades e participação por produto | Quantidade vendida e percentual do valor vendido por produto, considerando pedidos quitados não cancelados. | PRODUTO, ITEM_PEDIDO, PEDIDO, CUPOM_FISCAL, PAGAMENTO | G02 |
| K04 — taxa de recusa por forma | Tentativas atualmente recusadas divididas por todas as tentativas da forma, multiplicado por 100. | PAGAMENTO | G03 |
| K05 — valores aprovados e estornados por forma | Soma de cada situação atual, por data original da tentativa; não representa fluxo de caixa histórico de estornos. | PAGAMENTO | G03 |
| K06 — pendências e divergências financeiras | Relação de pedidos com saldo insuficiente, excesso, devolução pendente ou ausência de registros obrigatórios; a quantidade por situação pode ser calculada no dashboard. | PEDIDO, ITEM_PEDIDO, CUPOM_FISCAL, PAGAMENTO | G04 |
| K07 — demanda por dia, hora e canal | Contagem de pedidos registrados não cancelados, inclusive ainda não quitados, para orientar análise dos horários de movimento. | PEDIDO | G05 |
| K08 — frequência e valor por cliente identificado | Compras quitadas, valor acumulado e última compra no período; restrito a pedidos com `id_cliente`. | PEDIDO, ITEM_PEDIDO, CUPOM_FISCAL, PAGAMENTO | G06 |
| K09 — taxa de cancelamento por canal | Pedidos atualmente cancelados divididos por todos os pedidos registrados no período, multiplicado por 100; procedimento confirmado conforme RN23. | PEDIDO | G07 |
| K10 — saldo e disponibilidade atual | Unidades disponíveis e indicação de saldo zero. | PRODUTO, ESTOQUE | G08 |
| K11 — necessidade de reposição | Produtos com saldo menor ou igual ao mínimo cadastrado. | PRODUTO, ESTOQUE | G08 |
| K12 — fluxo de estoque por produto | Quantidades de entrada, baixa, perda, ajuste e retorno no período. | PRODUTO, MOVIMENTACAO_ESTOQUE | G09 |

O período usa início inclusivo e fim exclusivo. G01, G02 e G04–G07 selecionam pela data do pedido; G03 seleciona pela data da tentativa. Para apoiar a conferência de um dia civil, informar `@inicio` no início do dia e `@fim` no início do seguinte; G01 permanece agrupada por mês/canal e, nesse filtro de um dia, retorna somente seus valores. O **fechamento ao final de cada dia e sua execução exclusiva por gerentes estão confirmados** na entrevista de 08/11/2026, conforme RF31/RN33. O campo de referência usado pelo sistema existente e o horário exato de corte não foram informados.

As consultas refletem a **situação atual** dos registros; executá-las não efetiva nem registra um fechamento. Não é possível reconstruir um fechamento passado imutável nem atribuir um estorno ao dia/mês efetivo da devolução sem data/evento de estorno ou snapshots. O relato de estorno imediato não define o tratamento de eventuais devoluções após o fechamento. Reabertura, preservação dos valores fechados e regime de contabilização dessas exceções continuam pendentes de detalhamento.

Estoque, recebimentos e unidades de perdas/ajustes já têm suporte no modelo lógico. Validade/lotes, contas a pagar, campanhas e escala não têm tabelas. Não se propõem métricas de margem, valor financeiro de desperdício, eficácia promocional ou produtividade individual como se já fossem calculáveis. G08 mostra indisponibilidade atual; duração histórica de ruptura e confirmação da publicação nos canais exigem eventos adicionais. Tempos de preparo também exigem datas de cada transição, ausentes no esquema atual.

### Aplicações analíticas e de IA

- **Previsão de demanda:** séries de quantidades por produto, data e canal podem apoiar planejamento do abastecimento. Será necessário acumular histórico representativo e considerar que venda observada não mede demanda perdida por indisponibilidade.
- **Recomendação de produtos:** a coocorrência de produtos em ITEM_PEDIDO permite estudar combinações frequentes e sugestões complementares, sem exigir identificação pessoal de todos os compradores.
- **Segmentação de clientes:** frequência, valor e recência podem apoiar análises de clientes identificados. Pedidos anônimos não devem ser tratados como se pertencessem à mesma pessoa; o cadastro opcional limita a cobertura.
- **Detecção de anomalias:** padrões de recusas, divergências e cancelamentos podem gerar alertas para conferência humana. Um alerta não comprova fraude ou falha operacional.

Essas aplicações são propostas futuras. Os modelos devem ser comparados com referências simples e avaliados em períodos posteriores aos de treinamento, evitando uso de informações que só surgem após a previsão. O ambiente analítico deve restringir acesso a dados pessoais e utilizar identificadores pseudonimizados quando o nome ou documento não forem necessários.

## 2. Modelo Lógico Relacional

**Formato de entrega:** arquivo lógico nativo e editável do **brModelo 3** (`.brM3`), estruturado a partir dos `CREATE TABLE` de `WECOFFE/docs/script.sql`. A imagem abaixo foi renderizada pelo motor do brModelo após salvar e reabrir o arquivo nativo.

![Modelo lógico relacional da We Coffee no brModelo](./WECOFFE/modelagem/Modelo_Logico_WeCoffee_brModelo.png)

[Arquivo editável no brModelo 3](./WECOFFE/modelagem/Modelo_Logico_WeCoffee.brM3) · [Imagem do modelo nativo](./WECOFFE/modelagem/Modelo_Logico_WeCoffee_brModelo.png) · [Como abrir e editar](./WECOFFE/docs/modelo_logico_brmodelo.md)

Para editar, abrir o brModelo 3 e selecionar **Arquivo → Abrir**, escolhendo `Modelo_Logico_WeCoffee.brM3`. As versões anteriores [SVG](./WECOFFE/modelagem/Modelo_Logico_WeCoffee.svg) e [PNG](./WECOFFE/modelagem/Modelo_Logico_WeCoffee.png), geradas por JavaScript/PowerShell, continuam disponíveis como representações auxiliares.

Cada retângulo mostra o nome da tabela no topo, uma linha por coluna, o tipo ao lado do nome e os ícones nativos de participação em PK, FK e UNIQUE. O modelo lógico contém nove tabelas e 44 colunas, incluindo ESTOQUE e MOVIMENTACAO_ESTOQUE; o DER conceitual permanece com seis entidades. A chave composta de ITEM_PEDIDO é formada por id_pedido e id_produto. O relacionamento N:N conceitual foi convertido em duas relações 1:N por essa tabela associativa.

O arquivo nativo registra nove chaves primárias, cinco restrições UNIQUE e dez chaves estrangeiras com suas ligações. A FK de MOVIMENTACAO_ESTOQUE para ITEM_PEDIDO utiliza o par `(id_pedido, id_produto)`. A UNIQUE `(id_pedido, id_produto, tipo)` também é composta: seus campos não são únicos individualmente.

A cardinalidade junto a uma tabela indica quantas linhas dela podem estar relacionadas a uma linha da tabela oposta. CLIENTE e FUNCIONARIO são opcionais no pedido, enquanto cada item exige um pedido e um produto. As cardinalidades mínimas obrigatórias de item, cupom e tentativa representam as regras de negócio; sua garantia integral exige as rotinas transacionais descritas na Seção 1.5, além das FKs do DDL.

NOT NULL, DEFAULT e AUTO_INCREMENT estão no complemento dos campos no arquivo nativo; os CHECKs e o DDL de origem estão nas observações de cada tabela. As restrições também estão documentadas na **Seção 5 desta entrega**, com sua implementação declarativa no script da Seção 3.

## 3. Script SQL Completo

**Arquivo para entrega e execução:** [WECOFFE/docs/script.sql](./WECOFFE/docs/script.sql). **SGBD:** MySQL 8.0.16 ou superior; testado no **MySQL Community Server 8.0.46**, em 01/11/2026.

O arquivo contém, nesta ordem: CREATE DATABASE e USE; criação das nove tabelas com constraints; INSERT INTO da massa fictícia; SELECT com JOIN; UPDATE de preço atual; DELETE de produto sem referências; consultas gerenciais G01–G09; consultas de auditoria A01–A16. Usa InnoDB, utf8mb4 e collation utf8mb4_0900_as_cs, distinguindo maiúsculas e acentos nos domínios textuais.

### Execução do zero

1. Conectar-se ao MySQL com usuário autorizado a criar banco e tabelas. O nome `wecoffee_academico` deve estar livre; o script não remove nem reaproveita banco existente.
2. No MySQL Workbench, abrir `WECOFFE/docs/script.sql` e executar o arquivo inteiro, interrompendo em caso de erro. Alternativamente, no cliente mysql, executar `SOURCE C:/caminho/do/repositorio/WECOFFE/docs/script.sql;`.
3. Conferir a carga, os resultados gerenciais e as auditorias abaixo. A execução inclui UPDATE e DELETE demonstrativos sobre a própria massa fictícia.

O teste ocorreu em uma instância temporária inicialmente vazia, separada da instalação habitual, ouvindo somente em localhost. Resultado: **execução integral sem erros**. Evidências: [saída das consultas](./WECOFFE/docs/resultado_execucao_mysql.txt), [61 verificações aprovadas](./WECOFFE/docs/resultado_validacao_mysql.txt) e [validador PowerShell](./WECOFFE/docs/validar_script.ps1). Também passaram [4 verificações de atomicidade e concorrência](./WECOFFE/docs/resultado_concorrencia_mysql.txt), usando [duas conexões independentes em banco de teste separado](./WECOFFE/docs/validar_concorrencia_estoque.ps1). O validador exige cliente mysql e conexão com a instância de teste já carregada; não deve ser usado em dados operacionais.

A validação conferiu os totais sem multiplicação por JOIN, preservação do preço histórico e rejeição de violações de PK, FK, UNIQUE, NOT NULL, CHECK e exclusão de registros referenciados. Injeções temporárias, revertidas com ROLLBACK, comprovaram que A01–A04, A12 e A15 encontram os problemas esperados; a alteração de item com baixa passou a ser rejeitada por trigger. As regras entre tabelas ainda dependentes de serviço transacional continuam descritas na Seção 1.5; auditoria detecta inconsistência e não substitui prevenção.

### Catálogo das auditorias

| Código | Pergunta / controle | Regras verificadas | Resultado esperado na massa final |
|---|---|---|---|
| A01 | Pedido sem item? | RN11 | Nenhuma linha. |
| A02 | Pedido sem exatamente um cupom? | RN14 | Nenhuma linha. |
| A03 | Cupom sem tentativa de pagamento? | RN16 | Nenhuma linha. |
| A04 | Pedido em preparo, pronto ou entregue sem quitação? | RN13, RN19, RN20, RN22 | Nenhuma linha. |
| A05 | Cancelamento com devolução pendente? | RN23, RN24 | Pedido 9: R$ 48,00; exceção fictícia proposital para testar a auditoria, sem representar o fluxo normal imediato relatado. |
| A06 | Origem/totem incompatíveis? | RN07 | Nenhuma linha. |
| A07 | Referência órfã? | RN03, RN06, RN11, RN14, RN16 | Nenhuma linha. |
| A08 | Quantidade ou valor de pagamento inválido? | RN11, RN17 | Nenhuma linha. |
| A09 | Documento de cliente ou número fiscal duplicado? | RN02, RN15 | Nenhuma linha. |
| A10 | UPDATE demonstrativo alterou o histórico do preço? | RN12, no cenário controlado da massa | Nenhuma linha. |
| A11 | Recebimento aprovado acima do total? | RN13, RN19, RN20 | Pedido 7: total R$ 28,00, aprovado R$ 33,00, excesso R$ 5,00. |
| A12 | Saldo diverge do histórico? | RN25, RN26, RN29, RN32 | Nenhuma linha. |
| A13 | Item liberado sem baixa integral e única? | RN27 | Nenhuma linha. |
| A14 | Retorno sem cancelamento ou baixa compatível? | RN28 | Nenhuma linha. |
| A15 | Produto sem estoque ou configuração válida? | RN25, RN30 | Nenhuma linha. |
| A16 | Baixa em pedido recebido ou movimento sem rastreabilidade? | RN26, RN27, RN29 | Nenhuma linha. |

A04 examina a situação atual; não comprova em qual instante o pedido foi liberado. A10 compara somente o cenário conhecido da demonstração: não existe trilha que permita provar a imutabilidade de todos os preços históricos em produção. A05 não comprova devolução externa, que depende de confirmação; seu caso pendente é uma exceção de teste e não comprova atraso no sistema da unidade.

G01–G09 cobrem P1, P2 e todos os KPIs K01–K12 da Seção 1.6. G08 responde sobre saldo atual, indisponibilidade e reposição; G09 consolida movimentações. A cobertura de estoque está concluída neste recorte. Sincronização com canais externos e duração histórica da ruptura não são medidas pelo banco atual.

Os arquivos [esquema_logico.sql](./WECOFFE/modelagem/esquema_logico.sql) (núcleo original), [estoque_logico.sql](./WECOFFE/modelagem/estoque_logico.sql) (extensão lógica/física) e [consultas_gerenciais.sql](./WECOFFE/modelagem/consultas_gerenciais.sql) são recortes auxiliares. Para entrega e demonstração, utilizar somente `WECOFFE/docs/script.sql`, que reúne criação, carga, operações e consultas.

## 4. Massa de Dados

A carga está **incluída no arquivo [WECOFFE/docs/script.sql](./WECOFFE/docs/script.sql)**, nos blocos 4 e 4.2; não há arquivo separado a executar. O script cria as tabelas, insere a massa e aplica as rotinas que produzem os estados finais. Todos os nomes, clientes, preços, valores, identificadores de documentos, mínimos e movimentos são **fictícios**. Não foram importados cadastros, documentos pessoais ou valores de vendas da organização. CPF/CNPJ permanece NULL nos clientes da carga.

### 4.1 Relação com o contexto e porte da organização

A Seção 1.1 registra **oito funcionários da cafeteria**, quatro profissionais de limpeza e três seguranças terceirizados. Os oito funcionários são representados por oito pessoas fictícias no cadastro operacional; não são nomes dos profissionais reais. O projeto não inclui os terceirizados nesse cadastro de vendas/estoque nem transforma o exemplo de escala em dados operacionais.

O grupo informou não possuir os volumes reais de pedidos, clientes, cardápio ou estoque e autorizou dados fictícios em 01/11/2026. Portanto, não é possível justificar proporcionalmente a massa por um número real de vendas mensais que não foi levantado. A solução é uma **amostra funcional declarada de 60 pedidos selecionados em dois meses**, suficiente para testar processos e comparar períodos, sem apresentá-la como todo o movimento da cafeteria ou como volume observado. A divisão de 20 pedidos por canal é intencional para cobrir igualmente TOTEM, BALCÃO e DELIVERY; não representa participação real dos canais.

| Tabela | Registros finais | Justificativa do volume e vínculo com o levantamento |
|---|---|---|
| CLIENTE | 20 | Amostra fictícia de cadastros para permitir recorrência, compras sem cadastro e dois clientes sem pedidos (19 e 20). O total real de clientes não foi informado; 20 não é estimativa desse total. |
| FUNCIONARIO | 8 | Corresponde ao número confirmado de profissionais da cafeteria. Identidades e distribuição entre cargos são fictícias. Os quatro profissionais de limpeza e três de segurança terceirizados não operam este cadastro de vendas. |
| PRODUTO | 13 | Seleção didática de seis bebidas e sete alimentos para testar preços e combinações distintas, compatível com os tipos de produto do segmento. Não representa o tamanho real do cardápio. São 14 inserções: o cadastro temporário 8 é removido no exemplo de DELETE. |
| PEDIDO | 60 | Amostra selecionada: 15 pedidos em setembro e 45 em outubro de 2026. Os três canais têm 20 pedidos cada. Há pedidos anônimos, recorrência, pendências e cancelamentos, sem afirmar média diária ou mensal real. |
| ITEM_PEDIDO | 120 | Derivados dos 60 pedidos: de uma a três linhas por pedido, média de duas. Quantidades e preços da venda permitem conferir N:N, totais e consumo de estoque. |
| CUPOM_FISCAL | 60 | Exatamente um por pedido, inclusive cancelados preservados no histórico, conforme RN14; números SIM-2026 identificam documentos simulados. |
| PAGAMENTO | 72 | Uma tentativa inicial por pedido e 12 registros adicionais para divisão de conta ou nova tentativa após recusa. Cobre quatro formas e três situações, sem representar taxa real de recusa. |
| ESTOQUE | 13 | Um registro para cada produto que permanece cadastrado, conforme RN25. Mínimo cinco e saldos são escolhas de teste, não informações reais da unidade. |
| MOVIMENTACAO_ESTOQUE | 103 | Gerados pelos processos: 19 entradas selecionadas, 80 baixas de itens, um retorno, uma perda e dois ajustes. Permitem conciliação e testes de saldo. São um recorte de recebimentos, não um diário completo; o abastecimento diário relatado não significa reposição de todos os produtos todos os dias. |

A amostra resulta em **469 registros nas nove tabelas ao final do script**. O objetivo é cobrir situações do negócio com dependências consistentes, sem multiplicar registros apenas para aumentar volume. Os montantes de pedidos e pagamentos são derivados dos itens ou dos cenários de pendência; as FKs sempre apontam para cadastros existentes. As taxas e os indicadores calculados descrevem somente a massa fictícia.

### 4.2 Variedade e cenários demonstráveis

| Cenário | Exemplos da massa | Como conferir |
|---|---|---|
| Clientes recorrentes, anônimos e sem compras | Pedidos do cliente 1; pedidos sem id_cliente; clientes 19 e 20 sem pedidos. | G06 para frequência; teste de cobertura de clientes sem pedidos no validador. |
| Dois períodos e três canais | Setembro e outubro; TOTEM, BALCÃO e DELIVERY com 20 pedidos cada. | Alterar @inicio/@fim em G01–G07 e G09; conferir períodos e canais no validador. |
| Itens e formas de pagamento variadas | Uma a três linhas por pedido; PIX, Crédito, Débito e Dinheiro. | SELECT com JOIN e G02–G03. |
| Pagamento dividido | Pedido 3 e cinco novos pedidos: duas partes que somam o total. | G03–G04; não somar o total do pedido repetidamente por pagamento. |
| Recusa seguida de nova tentativa | Pedido 2 e cinco novos pedidos. | G03–G04; recusas permanecem no histórico. |
| Pendência, parcial e excesso | Pedidos 5/11 recusados, 6 parcialmente pago, 7 com excesso de R$ 5,00; novos pedidos repetem recusa/parcial. | G04; A11 retorna somente o pedido 7 com excesso. |
| Cancelamentos | Sete pedidos: 8 e 9, além de 18, 28, 38, 48 e 58. | G07; A05 retorna o pedido 9 com R$ 48,00 a devolver. |
| Cancelamento antes e depois da baixa | Pedido 9 sem baixa; pedido 8 baixado, cancelado e com retorno confirmado apenas do produto 1. Os cinco novos cancelamentos anteriores ao preparo têm pagamento estornado e não movimentam estoque. | G09 e A12–A16; estorno não repõe saldo automaticamente. |
| Falta de saldo e reposição | Produto 7 termina com zero; produto 6 com três unidades para mínimo cinco. | G08 retorna indisponibilidade e necessidade de reposição. |
| Recebimento, perda e ajustes | Entradas dos dois períodos, perda do produto 5 e ajustes dos produtos 3 e 4. | G09 e conciliação A12. |
| Preservação do preço histórico | UPDATE do produto 1 de R$ 10,00 para R$ 11,00 mantém R$ 10,00 nos itens anteriores. | SELECT de preço atual/histórico e A10. |

As datas das chamadas de rotina são fixadas pelo relógio da sessão somente durante a simulação e restauradas com SET TIMESTAMP=0. Os movimentos complementares ocorrem após a data/hora dos respectivos pedidos. Não são gerados pedidos liberados sem quitação ou saldo; os casos de pagamento parcial, recusa e excesso permanecem fora do preparo. A05 e A11 mostram pendências propositais, enquanto as demais auditorias não retornam violações estruturais na carga final. A devolução pendente de A05 é uma exceção fictícia para testar detecção de falha, não uma descrição do estorno imediato informado na entrevista.

### 4.3 Valores de referência e validação

Com o período padrão de outubro, G01 consolida **30 pedidos quitados não cancelados, R$ 1.574,00 e ticket médio global de R$ 52,47**, apresentados por canal. Em setembro, são nove pedidos quitados e R$ 501,00. Nos dois meses juntos, são 39 pedidos quitados, R$ 2.075,00 e ticket médio global de R$ 53,21. Pedidos cancelados, parcialmente pagos, recusados ou com excesso não entram nessas vendas quitadas.

O script foi executado do zero no **MySQL 8.0.46**, sem erros. Passaram [61 verificações de integridade e cobertura](./WECOFFE/docs/resultado_validacao_mysql.txt) e [quatro de atomicidade/concorrência](./WECOFFE/docs/resultado_concorrencia_mysql.txt). Os testes conferem contagens, meses, canais, clientes sem pedidos, situações financeiras, disponibilidade e totais; também injetam falhas revertidas com ROLLBACK. A [saída da execução](./WECOFFE/docs/resultado_execucao_mysql.txt) permite conferir os resultados. O registro de uso de LLM está na **Seção 6 desta entrega**.

## 5. Repositório GitHub e Dicionário de Dados

O relatório técnico está neste [Readme.md](./Readme.md), exibido pelo GitHub como README do repositório. O **dicionário completo está em um único arquivo HTML: [index.html](./index.html)**. Ele reúne as nove tabelas e 44 colunas físicas, expressões de composição e restrições por coluna: tipo, obrigatoriedade, PK/FK, unicidade simples/composta, valores permitidos, DEFAULT e geração automática. Os CHECKs completos e as regras transacionais também estão documentados nesse arquivo.

O [script MySQL de referência](./WECOFFE/docs/script.sql) define a implementação. Os tipos do HTML foram conferidos com ele, incluindo textos, decimais, datas e FKs compostas. ESTOQUE e MOVIMENTACAO_ESTOQUE aparecem somente na documentação lógica/física; o DER conceitual continua preservado.

O arquivo `02-03g_Exemplo_Dicionario_Dados.pdf` não está disponível no repositório nem teve localização informada. Foi preservado o formato existente de expressões e tabelas; a comparação exata com esse exemplo permanece pendente de acesso ao PDF. A síntese abaixo complementa o HTML e não exige outro arquivo de dicionário. As chaves são listadas também na Seção 1.3.

### CLIENTE

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_cliente` | `INT` | NOT NULL; PK; AUTO_INCREMENT (RN01). |
| `nome` | `VARCHAR(150)` | NOT NULL; texto não vazio (RN02). |
| `cpf_cnpj` | `VARCHAR(14)` | NULL permitido; UNIQUE; apenas 11 ou 14 dígitos. Padronizar sem pontuação; a checagem de comprimento/formato é proposta técnica, não valida dígitos verificadores (RN02). |

### FUNCIONARIO

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_funcionario` | `INT` | NOT NULL; PK; AUTO_INCREMENT (RN01). |
| `nome` | `VARCHAR(150)` | NOT NULL; texto não vazio (RN03). |
| `cargo` | `VARCHAR(80)` | NOT NULL; texto não vazio (RN03). |

### PEDIDO

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_pedido` | `INT` | NOT NULL; PK; AUTO_INCREMENT (RN01). |
| `id_cliente` | `INT` | NULL permitido; FK para CLIENTE (RN06, RN09). |
| `id_funcionario` | `INT` | NULL permitido; FK para FUNCIONARIO, inclusive no balcão (RN03, RN08). |
| `totem` | `VARCHAR(50)` | NULL nas demais origens; obrigatório e não vazio em TOTEM (RN07). |
| `nome_comanda` | `VARCHAR(150)` | NULL permitido; se preenchido, não vazio. Ausência usa id_pedido na chamada (RN10). |
| `data_hora` | `DATETIME` | NOT NULL; DEFAULT CURRENT_TIMESTAMP (RN06; padrão técnico proposto). |
| `origem_pedido` | `VARCHAR(10)` | NOT NULL; CHECK: TOTEM, BALCÃO ou DELIVERY (RN07). |
| `status_preparo` | `VARCHAR(12)` | NOT NULL; DEFAULT RECEBIDO; CHECK: RECEBIDO, EM_PREPARO, PRONTO, ENTREGUE, CANCELADO (RN22–RN23; cancelamento confirmado no levantamento). |

### CUPOM_FISCAL

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_cupom_fiscal` | `INT` | NOT NULL; PK; AUTO_INCREMENT (RN01). |
| `id_pedido` | `INT` | NOT NULL; UNIQUE; FK para PEDIDO (RN14). |
| `numero` | `VARCHAR(50)` | NOT NULL; UNIQUE na unidade; texto não vazio (RN15). |
| `data_hora_emissao` | `DATETIME` | NOT NULL; DEFAULT CURRENT_TIMESTAMP (RN15; padrão técnico proposto). |

### PAGAMENTO

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_pagamento` | `INT` | NOT NULL; PK; AUTO_INCREMENT (RN01). |
| `id_cupom_fiscal` | `INT` | NOT NULL; FK para CUPOM_FISCAL (RN16). |
| `forma_pagamento` | `VARCHAR(10)` | NOT NULL; CHECK: PIX, Crédito, Débito ou Dinheiro (RN17). |
| `valor_pagamento` | `DECIMAL(12,2)` | NOT NULL; CHECK > 0 (RN17). |
| `status_pagamento` | `VARCHAR(10)` | NOT NULL; CHECK: Aprovado, Recusado ou Estornado (RN17, RN24; Estornado após devolução confirmada). |
| `data_hora_pagamento` | `DATETIME` | NOT NULL; DEFAULT CURRENT_TIMESTAMP (RN17; padrão técnico proposto). |

### ITEM_PEDIDO

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_pedido` | `INT` | NOT NULL; PK composta e FK para PEDIDO (RN11). |
| `id_produto` | `INT` | NOT NULL; PK composta e FK para PRODUTO (RN11). |
| `quantidade` | `INT` | NOT NULL; inteiro; CHECK > 0 (RN11). |
| `preco_unitario` | `DECIMAL(12,2)` | NOT NULL; preço histórico (RN12). Sem limite numérico adicional. |

### PRODUTO

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| `id_produto` | `INT` | NOT NULL; PK; AUTO_INCREMENT (RN01). |
| `nome` | `VARCHAR(150)` | NOT NULL; texto não vazio (RN04). |
| `preco` | `DECIMAL(12,2)` | NOT NULL; CHECK > 0 (RN04). |

### ESTOQUE — somente no modelo lógico

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| id_produto | INT | PK, FK para PRODUTO; obrigatório; um saldo por produto (RN25). |
| quantidade_disponivel | INT | NOT NULL, DEFAULT 0, CHECK >= 0; saldo materializado mantido pelo trigger dos movimentos (RN25, RN31–RN32). |
| estoque_minimo | INT | NOT NULL, DEFAULT 0, CHECK >= 0; limite configurável; cinco é apenas exemplo da carga (RN30). |
| data_atualizacao | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP; recebe a data/hora do último lançamento aplicado (RN26). |

### MOVIMENTACAO_ESTOQUE — somente no modelo lógico

| Coluna | Tipo | Integridade e regra |
|---|---|---|
| id_movimentacao | INT | PK, AUTO_INCREMENT, NOT NULL (RN26). |
| id_produto | INT | NOT NULL; FK para ESTOQUE e parte da FK composta para ITEM_PEDIDO (RN25–RN27). |
| id_pedido | INT | NULL em entradas, perdas e ajustes; obrigatório em VENDA/RETORNO. FK composta (id_pedido,id_produto) para ITEM_PEDIDO (RN27–RN28). |
| id_funcionario | INT | NOT NULL; FK para FUNCIONARIO; responsável pelo lançamento, independente do funcionário opcional da venda (RN26, RN29). |
| tipo | VARCHAR(15) | NOT NULL; CHECK: ENTRADA, VENDA, PERDA, AJUSTE_ENTRADA, AJUSTE_SAIDA ou RETORNO (RN26–RN28). |
| quantidade | INT | NOT NULL, CHECK > 0; magnitude positiva, com sinal determinado pelo tipo. VENDA e RETORNO correspondem ao item integral (RN26–RN28). |
| data_hora | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP (RN26). |
| motivo | VARCHAR(255) | NOT NULL e texto não vazio (RN26, RN29). |
| referencia | VARCHAR(80) | NOT NULL, UNIQUE e texto não vazio; identifica a operação para impedir repetição (RN29). |

A combinação (id_pedido,id_produto,tipo) é UNIQUE: permite no máximo uma VENDA e um RETORNO por item. Nas movimentações sem pedido, o NULL permite vários recebimentos, perdas e ajustes para o mesmo produto. Todas as FKs usam RESTRICT. UPDATE e DELETE de movimentos são rejeitados; corrigir por novo ajuste com motivo. O sistema deve conferir o produto e a referência antes de repetir uma solicitação com falha de comunicação.

**Rotinas implementadas:** sp_registrar_movimentacao recebe produto, tipo, quantidade, responsável, motivo e referência; sp_liberar_preparo recebe pedido e responsável e executa baixa/liberação atômicas; sp_retornar_estoque recebe pedido, produto, responsável, confirmação de revenda, motivo e referência. Chamá-las fora de uma transação já aberta: cada rotina gerencia sua própria transação. As contas da aplicação devem receber EXECUTE nas rotinas, sem escrita direta nas tabelas de saldo e movimentos; a criação dessas contas/perfis permanece fora do script acadêmico. O usuário administrativo do banco pode alterar tabelas diretamente, por isso A12 e A15 também conferem desvios de saldo e cobertura.

Todas as FKs usam ON DELETE RESTRICT e ON UPDATE RESTRICT, preservando referências e histórico. Colunas sem DEFAULT explícito não recebem um valor de negócio presumido: a aplicação deve informar os campos obrigatórios. Valores monetários usam decimal exato com duas casas; os limites de capacidade devem ser confirmados antes da implantação. Os nomes e códigos fiscais não recebem unicidade adicional além da especificada.

CHECK não garante regras entre tabelas. A baixa, a quitação na liberação, o bloqueio da composição após baixa e a preservação dos movimentos estão implementados por rotinas e triggers. A conferência física de aptidão para revenda e a confirmação externa do estorno continuam dependentes do responsável. A conclusão de todo pedido com cupom/tentativa exige serviço próprio e é conferida por A01–A03.

## 6. Uso de Inteligência Artificial — Massa de Dados

| Item | Registro |
|---|---|
| Ferramenta/modelo | Codex, assistente com LLM, para gerar os INSERTs fictícios e atualizar os testes e a documentação. JavaScript/Node.js para geração determinística; MySQL Community Server 8.0.46 para execução; PowerShell para verificações automatizadas. Não se atribui à IA a confirmação de volumes reais. |
| Data e objetivo | 01/11/2026: ampliar a amostra e cobrir clientes sem compras, períodos distintos, canais, pagamentos, cancelamentos e estoque com integridade referencial. |
| Prompt do grupo | Solicitação da Seção 4: massa fictícia, volume justificado por tabela, variedade de cenários, consistência e registro do uso de LLM. Complemento recebido: “Não tenho pode usar dados ficticios ou os que já estão registrado em algum lugar por aqui”. |
| Instrução operacional de geração | Gerar 45 pedidos complementares aos 15 casos existentes, em setembro/outubro, com uma a três linhas, clientes recorrentes e sem pedidos, oito funcionários fictícios, novas tentativas e pagamentos divididos; manter saldos não negativos e os casos controlados das auditorias. Essa instrução descreve o critério aplicado pelo assistente, não uma nova informação sobre a unidade. |
| Dados utilizados | Apenas estrutura, regras e contagens não pessoais já documentadas: oito funcionários da cafeteria, três canais e tipos de processo. Nenhum cadastro, nome de pessoa real, documento pessoal, venda real ou preço real foi usado como dado da carga. |
| Resultado gerado | Carga estática em WECOFFE/docs/script.sql: 20 clientes, oito funcionários, 13 produtos, 60 pedidos, 120 itens, 60 cupons, 72 pagamentos, 13 estoques e 103 movimentos finais. |
| Ajustes e revisão | Complementados os cenários iniciais, preservados os casos de auditoria 7/9 e a falta de saldo do produto 7; reservados clientes 19/20 sem pedidos; mantido produto 8 para o DELETE. Corrigidos totais esperados nos testes e conferidos meses, quantidades, referências e horários. Cabeçalhos G/A foram completados para manter a rastreabilidade. |
| Ajustes manuais e origem | Não houve edição manual de dados reais pela unidade nem fornecimento de volumes reais. As escolhas de amostra e correções foram aplicadas pelo assistente com ferramentas, a partir da autorização do grupo. A validação humana posterior do grupo não é apresentada como já realizada. |
| Verificação independente da geração | Execução real do arquivo SQL e asserções automatizadas de resultado: 61 verificações gerais/de cobertura e quatro de atomicidade/concorrência. A execução, não apenas o texto gerado, foi usada para conferir as contagens e regras. |
| Limitações | O volume é uma amostra funcional fictícia, sem proporcionalidade comprovada com vendas mensais reais. Médias e taxas da carga não podem ser atribuídas à organização. Dados operacionais futuros devem substituir a amostra em eventual implantação. |

O histórico de uso de IA da Entrega 1 permanece na Seção 9 daquela entrega. Esta Seção 6 atende especificamente à geração e revisão da massa de dados da Entrega 2.

## 7. Demonstração na Apresentação Final

Utilizar o mesmo [WECOFFE/docs/script.sql](./WECOFFE/docs/script.sql): mostrar o detalhamento com JOIN, conferir o preço histórico após UPDATE e a exclusão do produto temporário; executar G01–G09 conforme a rastreabilidade da Seção 1.6; executar A01–A16 e explicar as ocorrências esperadas de A05 e A11. A demonstração não utiliza consultas alternativas nem interpreta ausência de venda como ruptura de estoque. Esta seção define o roteiro; a apresentação ainda não foi realizada.

# Conclusão

O modelo conceitual descrito no README representa atendimento, pedidos, produtos, documentos fiscais, pagamentos, preparação e entrega, preservando os cadastros de clientes e funcionários. O cadastro de fornecedor foi retirado do recorte documental. O mapeamento também registra organização da equipe, limpeza e segurança, abastecimento diário, limitações de acesso a contas a pagar e perdas, relato sobre validade e campanhas de parceria. O estoque foi definido com base nas práticas confirmadas pelo grupo em 01/11/2026 e implementado no modelo lógico e no SQL, preservando o DER conceitual por orientação explícita. Os requisitos RF24 e RF25 contemplam apenas o registro informativo de campanhas e o registro manual de escala, demonstrado com nomes fictícios. Sua representação no dicionário e no DER permanece pendente; concessão e resgate de benefícios não integram esta etapa.

A modelagem foi estruturada para manter consistência entre os processos levantados, os requisitos, as regras de negócio, o dicionário de dados e o DER.

---

## Alterações

Os registros abaixo preservam as decisões de cada data; referências antigas ao estoque como lacuna descrevem versões anteriores, superadas pela revisão de 01/11/2026 registrada ao final deste README.

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

### Estoque concluído a partir do modelo lógico — 01/11/2026

- Registrada a confirmação do grupo de controle por produto pronto e baixa na liberação para preparo, além das regras de recebimento, cancelamento, retorno apto para revenda, perdas, ajustes e mínimo.
- Preservados integralmente o DER conceitual, o arquivo brModelo e as exportações conceituais: seis entidades, cinco relacionamentos e 26 atributos. Estoque e seus atributos aparecem somente nas camadas lógica e física, conforme orientação expressa do grupo.
- Acrescentadas ESTOQUE e MOVIMENTACAO_ESTOQUE: nove tabelas e 44 colunas no modelo lógico. Atualizados diagrama SVG/PNG, dicionário lógico no README e complemento lógico no HTML.
- Incluídos RF26–RF30 e RN25–RN32; documentadas materialização do saldo, idempotência, responsável pelo lançamento e escolhas técnicas de retorno integral por item.
- Atualizado WECOFFE/docs/script.sql com saldo inicial por produto, movimentos imutáveis, rotinas de recebimento/ajuste, baixa atômica e retorno confirmado. Cancelamento e estorno não repõem estoque automaticamente.
- Acrescentadas G08–G09, KPIs K10–K12 e auditorias A12–A16, fechando a rastreabilidade de P2. Atualizados massa fictícia e roteiro da apresentação.
- Testado o script do zero no MySQL 8.0.46: 54 verificações gerais e de estoque, mais quatro de atomicidade/concorrência. Duas conexões disputaram o mesmo saldo e apenas uma saída foi confirmada. Arquivos de evidência estão em docs.
- Não foram inventados registros reais de estoque ou perdas, valores mínimos reais, nova visita ou acesso a sistemas internos. Dados de demonstração permanecem fictícios. SQLite não foi utilizado; o SGBD permanece MySQL.

### Ampliação e documentação da massa fictícia — 01/11/2026

- Ampliada a carga em WECOFFE/docs/script.sql para 60 pedidos selecionados em setembro/outubro, com 469 registros finais nas nove tabelas; preservados os cenários anteriores e os arquivos conceituais/lógicos.
- Ajustado FUNCIONARIO para oito pessoas fictícias, em correspondência com o porte confirmado da cafeteria. Criados clientes sem pedidos e produtos complementares; nenhum dado pessoal ou valor real de venda foi utilizado.
- Registrada na Seção 1.1 a ausência de volumes reais de pedidos/cadastros e a autorização do grupo para usar dados fictícios. A Seção 4 justifica cada tabela como amostra de testes, sem afirmar um volume mensal real.
- Acrescentada a Seção 6 de uso de IA, com ferramenta, prompts, critérios de geração, ajustes e limites. Mantido o histórico anterior de IA.
- Atualizados valores de referência, evidências e testes: execução do zero no MySQL 8.0.46, 61 verificações gerais/de cobertura e quatro de atomicidade/concorrência aprovadas.

### Consolidação do dicionário HTML e organização do repositório — 01/11/2026

- Consolidado index.html como único dicionário HTML: nove tabelas, 44 colunas, tipos e restrições alinhados ao SQL vigente, incluindo ITEM_PEDIDO, ESTOQUE e MOVIMENTACAO_ESTOQUE.
- Explicitados obrigatoriedade, unicidade simples/composta, domínios, CHECKs, valores padrão, AUTO_INCREMENT e regras transacionais, sem acrescentar estoque ao DER conceitual.
- Atualizada a Seção 5 do relatório e corrigidos os links para WECOFFE/docs após a reorganização dos arquivos. Ajustados os caminhos relativos dos geradores do diagrama.
- Verificada a cobertura das tabelas/colunas do HTML contra os CREATE TABLE do script. Nenhuma alteração de estrutura SQL ou massa de dados nesta revisão.
- Registrada a limitação de acesso ao PDF 02-03g_Exemplo_Dicionario_Dados.pdf; a aderência exata ao exemplo depende de sua disponibilização.

### Confirmações de fechamento e estorno — 09/11/2026

- Registrada a entrevista de 08/11/2026 com o auxiliar geral como fonte do fechamento diário exclusivo dos gerentes e do cancelamento da nota/pedido com estorno imediato pelo cartão e balanceamento automático no sistema existente.
- Atualizados processos, pendências, RF16/RF18/RF21/RF23, RNF03, RN17/RN23/RN24, dicionários e interpretação dos indicadores; acrescentados RF31 e RN33 para formalizar o fechamento.
- Alinhados a matriz de acesso do HTML e os comentários SQL, distinguindo procedimentos confirmados, escolhas técnicas e funcionalidades ainda sem implementação.
- Mantidos o esquema de nove tabelas/44 colunas e a massa fictícia. A05 continua como exceção de teste. Corte exato, reabertura, estornos posteriores e demais permissões não foram confirmados pela entrevista.
