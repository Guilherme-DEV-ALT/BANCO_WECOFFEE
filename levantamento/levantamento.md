# Levantamento da unidade We Coffee — Av. Paulista, 1111

Organização: MOONLIGHT COFFEE CAFETERIA LTDA., nome comercial We Coffee. Este documento organiza o material de campo e as atualizações relatadas pelo grupo; o relatório técnico final permanece no [README da raiz](../README.md).

## 1. Fontes, visitas e limites

| Fonte | Data registrada | Informações |
|---|---|---|
| Entrevista inicial com Daniel Porrino, gerente | **30/08/2026** | Atendimento por três canais, processos de pedidos/pagamentos, dificuldade de consolidação mensal. Contato no README. Data informada pelo integrante em 10/11/2026. |
| Atualização pelo grupo | 28/10/2026 | 8 funcionários, 4 profissionais de limpeza e 3 de segurança terceirizados; abastecimento diário; campanha CITI; falta de acesso a contas a pagar e perdas. Não equivale a nova visita. |
| Confirmação de regras pelo grupo | 01/11/2026 | Estoque de produtos prontos; baixa na liberação; preservação de histórico; massa fictícia autorizada. |
| Entrevista com Leandro Viana, auxiliar geral | 08/11/2026, relatada em 09/11/2026 | Fechamento diário por gerentes; cancelamento de nota/pedido; estorno imediato pelo cartão e balanceamento automático. |
| Complemento e correção E1 fornecidos nesta conversa | 10/11/2026 | Mais de 100 pedidos/dia e mais de 5 mil/mês; avaliação do professor. Volume aproximado, sem extração do sistema. |

Os cinco integrantes são os identificados no README.

As [fotos da visita](../WECOFFE/Comprovante_Presença_WECOFFE.jpg) e [do grupo no interior](../WECOFFE/Registro_Grupo_WeCoffee.jpg) estão em JPG no repositório. Comprovam registro do grupo no local; é necessário conferir e documentar qual foto comprova a entrevista com o responsável. Vídeos mencionados não foram disponibilizados como arquivos.

### Respostas dos responsáveis e observação relatada

As entrevistas relatam três canais, comanda, pagamentos divididos, disponibilidade, fechamento e cancelamento. A observação presencial da rotina foi relatada pelo grupo no README, especialmente registro e identificação do pedido; não há diário de observação datado que permita atribuir cada achado a uma visita específica. O assistente não realizou entrevista ou visita. A consolidação abaixo não transforma respostas em observação direta.

## 1.1 Porte e uso da amostra

Mais de 100 pedidos por dia e mais de 5 mil por mês, conforme atualização de 10/11. Oito funcionários operacionais e sete terceirizados compõem as 15 pessoas informadas. Os 60 pedidos fictícios distribuídos em setembro/outubro são amostra funcional selecionada para testes, sem pretensão de representar todo esse volume ou as participações reais dos canais. Cadastros, preços e saldos são fictícios; o número real de clientes/produtos e a escala individual não foram fornecidos.

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
8. Atualizar requisitos, dicionário e DER após validar os dados e a ampliação do modelo. O registro da pesquisa e da geração da escala está na Seção 6.1; a complementação dos processos e o registro das lacunas estão na Seção 6.2.

## Fluxograma
![Fluxograma dos processos da We Coffee](<../WECOFFE/modelagem/drawio.jpg>)

### Legenda

| Elemento | Significado |
|---|---|
| 🟢| Início / Fim |
| ▭ | Processo / Atividade |
| ♦️| Decisão |
| Setas | Fluxo de execução |

---

## 3. Requisitos, regras e validação

Os requisitos RF e RNF e as regras RN vigentes estão na [Seção 1.1 do relatório](../README.md), com os campos envolvidos. O [dicionário HTML](../index.html) detalha cada coluna física. A [avaliação da E1](./avaliacao_entrega1.md) registra os apontamentos fornecidos pelo grupo; a tabela de correções fica no relatório.

O [relatório da revisão final](../WECOFFE/docs/revisao_final_2026-11-10.md) identifica lacunas de escopo e de comprovação. Os dados de campo continuam sujeitos à validação do grupo; nenhum requisito pendente de confirmação foi convertido em informação real apenas por ter sido sugerido pela IA.
