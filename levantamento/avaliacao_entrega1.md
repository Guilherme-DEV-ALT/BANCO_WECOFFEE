# Avaliação da Entrega 1 fornecida pelo grupo

Fonte: texto da avaliação do professor encaminhado pelo integrante na conversa de **10/11/2026**. Este arquivo organiza os apontamentos para rastreabilidade; não altera a nota nem representa nova correção docente. O relatório final e a resposta a cada apontamento estão no [README](../README.md).

**Repositório avaliado:** https://github.com/Guilherme-DEV-ALT/BANCO_WECOFFEE. Nota aplicada igualmente aos cinco integrantes: **0,98 / 1,60**. Cálculo informado: 1,60 − 0,45 = 1,15; fator de evidência de contato/entrevista × 0,85 = 0,9775, arredondado para 0,98.

| Critério | Resultado recebido e apontamentos |
|---|---|
| 1. LEIA-ME | Aceito por decisão do professor apesar do nome Readme.md. Havia outro README divergente em WECOFFE; foi corrigido o da raiz. |
| 2. Integrantes | Aceito: cinco integrantes com RGM. |
| 3.1 Organização real | Aceito: razão social, CNPJ 34.706.031/0001-84, site, Av. Paulista, 1111 e link do Google. |
| 3.2 Contato/entrevista | Contato relatado, mas nenhuma foto/vídeo de visita no repositório avaliado; imagens disponíveis eram logotipos. Contradição entre “a gerente” e o contato Daniel Porrino. Fator × 0,85. |
| 4. Caracterização | Aceita com seis funcionários e três canais informados na versão avaliada; problemas de fechamento mensal e disponibilidade. Oito funcionários e sete terceirizados são atualização posterior, já registrada no projeto. |
| 5. Processos | Parcial: seis descrições de uma linha e fluxograma. Faltavam cardápio/preços, cancelamento/estorno, contas a pagar, perdas e escala. Cobertura informada: 7,5 de 13 = 58%. Desconto: 0,10. |
| 6. Requisitos e regras conceituais | Aceitos: específicos dos canais, conta dividida e integração com TOTVS citada na versão avaliada. A aceitação não comprova que exista integração no SQL atual. |
| 7. Documentação dos requisitos | Aceita: RF em tabela ligada às entidades e RNF separadas. |
| 8. Regras de negócio | Parcial: restrições legais/fiscais/sanitárias e cancelamento insuficientes. Cobertura: 7,5 de 13 = 58%. Desconto: 0,05. |
| 9. Dicionário | Parcial: faltavam item 5 (logs), item 6 (matriz de acesso/retenção) e leitura das expressões. Desconto: 0,10. |
| 10. DER | Parcial: cardinalidades mín./máx. presentes e sem FKs, mas sem atributos desenhados. Relacionamento espúrio “É pago por” entre PEDIDO e ITEM_PEDIDO duplicava “Possui”; quantidade/preço apenas no dicionário. Desconto: 0,20. |
| 11. Justificativa técnica | Aceita: decisões e alternativas rejeitadas. |
| 12. Uso de IA | **Aceito.** Registro dos oito itens exigidos e dos prompts utilizados. O contexto da comparação com um README de terceiro está apresentado no [detalhamento deste critério](#criterio-12-uso-de-ia), com referência à declaração do grupo. |

## Cobertura de processos na versão avaliada

| Processo | Situação informada pelo professor |
|---|---|
| Pedido por totem, balcão e aplicativo | Coberto |
| Pagamento e conta dividida | Coberto |
| Preparo e entrega | Coberto |
| Cardápio e preços | Ausente |
| Fechamento mensal/análise | Coberto |
| Cancelamento/estorno | Ausente |
| Solicitação de fornecimento | Coberto |
| Recebimento/entrada no estoque | Coberto |
| Cadastro de compras/fornecimento | Parcial; o texto encaminhado contém “Cadastro de morte”, expressão ambígua que exige conferência no original da avaliação. |
| Contas a pagar | Ausente |
| Disponibilidade/estoque | Coberto |
| Escala | Ausente |
| Perdas/desperdício | Ausente; o texto encaminhado contém “Perdas / Escrevi”. |

As expressões ambíguas acima foram preservadas como observações, sem tratá-las como novos processos confirmados.

## Cobertura de regras na versão avaliada

| Regra esperada | Situação informada |
|---|---|
| Canal definido | Coberta |
| Referência a totem/funcionário conforme canal | Coberta |
| Conta dividida | Coberta |
| Preço histórico no item | Coberta; texto encaminhado apresenta “sem item”. |
| Estoque não negativo | Coberta |
| Entrada com fornecedor/data/produtos | Coberta |
| Esgotado indisponível nos canais | Parcial |
| Fornecedor alternativo com autorização | Parcial |
| Validade/vigilância sanitária | Parcial; reposição diária não comprova dispensa de cuidados de validade. |
| LGPD/CPF | Parcial; constava apenas no dicionário. |
| Cancelamento/estorno | Ausente |
| Cupom fiscal | Ausente |
| Descontos/programa do aplicativo | Ausente |

## Observações sobre o DER avaliado

O professor indicou como essenciais PRODUTO, PEDIDO/ITEM_PEDIDO, PAGAMENTO, FUNCIONÁRIO/TOTEM, ESTOQUE e FORNECEDOR/ENTRADA_ESTOQUE; todos constavam na imagem então avaliada. CLIENTE era desejável e estava presente; INSUMO foi sugerido como desejável, sem obrigação de inclusão. ITEM_PEDIDO e ITEM_ENTRADA apareciam como entidades, mas seus atributos só no dicionário.

O DER **atual** já é diferente: tem seis entidades e CONTÉM com quantidade/preço. A retirada posterior de compras/fornecedor e a manutenção de estoque apenas no lógico precisam ser avaliadas contra o escopo da Entrega 2; não se afirma que a versão atual recebeu aceite do professor.

<a id="criterio-12-uso-de-ia"></a>

## Detalhamento do critério 12 — Uso de Inteligência Artificial

**Resultado na Entrega 1: aceito.** A avaliação reconheceu o preenchimento dos oito itens e a transcrição dos prompts. O quadro abaixo organiza as evidências registradas no projeto; os usos posteriores de IA permanecem documentados na [Seção 6 do README](../README.md#6-uso-de-inteligência-artificial).

| Item exigido | Evidência registrada no projeto |
|---|---|
| **1. Ferramenta e etapa** | ChatGPT na organização do relatório, análise de requisitos, revisão de entidades e cardinalidades e estruturação do dicionário. As revisões posteriores com Codex estão identificadas por etapa e data no README. |
| **2. Motivação** | Organizar o levantamento, conferir a aderência ao esqueleto do professor e identificar inconsistências entre processos, requisitos, regras, dicionário e diagramas. |
| **3. Prompts utilizados** | Cinco solicitações de apoio ao desenvolvimento estão transcritas no [registro de prompts](../README.md#prompts-de-apoio-ao-desenvolvimento), incluindo a comparação com um trabalho de referência. O pedido da revisão final de 10/11/2026 também foi preservado. |
| **4. Resposta recebida** | Sugestões de organização do documento, identificação de entidades, revisão de relacionamentos e cardinalidades e explicitação de requisitos e regras. O histórico não apresenta a resposta integral de cada conversa. |
| **5. Fontes consultadas e verificadas** | Enunciado da atividade, levantamento e relatos do grupo, README do próprio projeto e artefatos de modelagem. O uso de um README de terceiro como referência comparativa foi declarado pelo grupo; esse arquivo não está disponível entre os materiais desta revisão. |
| **6. Trechos rejeitados ou corrigidos** | O histórico registra a revisão da hipótese de pagamento único. O modelo atual relaciona PEDIDO a CUPOM_FISCAL e este a vários PAGAMENTOs. A decisão antiga de manter saldo em PRODUTO foi substituída pela estrutura lógica de ESTOQUE e MOVIMENTACAO_ESTOQUE. |
| **7. Justificativa da escolha final** | As sugestões foram adaptadas aos relatos da unidade e às decisões documentadas pelo grupo. A estrutura vigente deve ser conferida nos artefatos atuais; os registros históricos não substituem as decisões posteriores. |
| **8. Reflexão crítica** | A IA auxilia a organização e a revisão, mas suas respostas precisam ser confrontadas com o levantamento e a execução técnica. Um exemplo de outro projeto não comprova regras da We Coffee. A responsabilidade pelo conteúdo e pela validação final permanece com os integrantes. |

### Contexto da referência ao README de terceiro

No registro de uso de IA do projeto, o grupo declarou ter utilizado **o esqueleto do professor, o README da We Coffee e o README de um amigo** para comparar a estrutura dos trabalhos e identificar possibilidades de melhoria. O prompt registrado foi:

> Com base nesses dois veja se bate o que está sendo pedido, esse ultimo que te mandei foi um exemplo de um amigo meu e veja o que o dele está certo e nosso errado

A explicação complementar do grupo e os demais prompts estão organizados no [README](../README.md#comparacao-com-trabalho-de-referencia). Essa declaração documenta a finalidade relatada para a comparação. O arquivo de referência e a resposta específica dessa interação não foram disponibilizados para conferência nesta revisão.

A avaliação recebida menciona uma observação sobre o README de terceiros, mas não reproduz seu conteúdo. Por isso, esta síntese preserva o resultado **aceito** e o contexto documentado, sem atribuir ao professor uma conclusão adicional.

### Fontes desta organização documental

- **Avaliação da Entrega 1:** texto fornecido pelo integrante em 10/11/2026, sintetizado neste arquivo.
- **Enunciado da Entrega 2, Seção 6:** origem dos oito itens de documentação do uso de IA.
- **[README do projeto, Seção 6](../README.md#6-uso-de-inteligência-artificial):** registro dos prompts, respostas resumidas, decisões e revisões.
- **[UNESCO — Guidance for generative AI in education and research](https://www.unesco.org/en/articles/guidance-generative-ai-education-and-research)**, publicação de 2023, consultada em 10/11/2026: referência complementar sobre abordagem centrada nas pessoas para o uso de IA na educação. Não constitui critério adicional de correção do trabalho.
