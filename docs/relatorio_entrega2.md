# Relatório de alterações e próximos passos — Entrega 2

Data: **27/10/2026**. Projeto: **We Coffee — ADS**. Documento destinado ao grupo e ao envio solicitado para guilherme.souza1006@gmail.com.

## Situação da entrega

A parte técnica foi implementada: relatório principal, levantamento organizado, modelos conceitual e lógico editáveis, dicionário HTML, script MySQL com massa fictícia e consultas, testes, fluxograma e apresentação de oito minutos. O banco foi executado em MySQL 8.4.13, em schema vazio separado, e **31 testes passaram**. As evidências estão salvas no repositório.

A entrega ainda depende de informações de campo e de validação acadêmica. Não se declara atendimento integral aos critérios do professor enquanto essas pendências não forem resolvidas. Estoque e recebimentos foram incluídos **como proposta técnica a validar**, conforme autorização do usuário, e não como fatos confirmados em uma nova entrevista.

## Alterações realizadas

| Área | Alteração e motivo | Arquivo principal |
|---|---|---|
| Relatório | Organização conforme o esqueleto, P1/P2, RF/RNF, RN01–RN28, normalização, justificativas, KPIs, rastreabilidade e uso de IA. Nome da raiz padronizado como README.md. | [README](../README.md) |
| Levantamento | Separação entre relato disponível, observação, propostas e dados ausentes. Foto de presença copiada como JPG sem ser apresentada como foto de entrevista. | [Levantamento](../levantamento/levantamento.md) |
| Conceitual | Oito entidades, sete relacionamentos, 36 atributos, sem FKs. Mantidos atributos nos relacionamentos CONTÉM e RECEBE. Totem continua atributo de PEDIDO. | [brModelo conceitual](../WECOFFE/modelagem/Modelo_Conceitual_WeCoffee.brM3) |
| Lógico | Dez tabelas, 44 colunas, nove FKs e duas PKs compostas. Tipos, chaves e cardinalidades expressos no diagrama. Associações aparecem como tabelas apenas nesta conversão. | [SVG lógico](../WECOFFE/modelagem/Modelo_Logico_WeCoffee.svg) · [brModelo lógico](../WECOFFE/modelagem/Modelo_Logico_WeCoffee.brM3) |
| Dicionário | Um único HTML, adequado à orientação de ADS: tipos, PK/FK, NULL, unicidade, padrões, restrições e informações derivadas. | [Dicionário](../index.html) |
| Implementação | DDL, constraints, views, triggers, rotinas transacionais, carga, JOIN, UPDATE/DELETE demonstrativos com rollback, G01–G09 e A01–A11. | [SQL completo](script.sql) |
| Integridade | 31 cenários verificam SQLSTATE, regras entre tabelas, cancelamento, falta de saldo e reversão de operações. | [Testes](testes_integridade.sql) · [resultado](resultado_testes.txt) |
| Fluxo | Recebimento, quitação, baixa única, cancelamento, devolução física e estorno financeiro representados separadamente. | [Fluxograma](../WECOFFE/modelagem/Fluxograma_WeCoffee.svg) |
| Apresentação | Oito slides editáveis com resultados reais da execução sobre dados fictícios, notas e roteiro de 480 segundos. | [PPTX](../apresentacao/WeCoffee_Entrega2.pptx) · [roteiro](../apresentacao/roteiro.md) |

O PDF atual é [Modelo_Conceitual_WeCoffee_Entrega2.pdf](../WECOFFE/modelagem/Modelo_Conceitual_WeCoffee_Entrega2.pdf). O antigo WeCoffee_BRModelo.pdf na raiz foi preservado como versão anterior; não deve ser confundido com o modelo atualizado.

A configuração .gitattributes preserva PDFs, arquivos brModelo, apresentações e imagens como binários, evitando conversão de quebras de linha pelo Git.

Não foram adicionados Python, geradores auxiliares, servidores ou pasta tmp ao projeto. As ferramentas de geração e validação foram utilizadas fora dele, em pastas temporárias do sistema. Não foi criado serviço permanente de banco de dados.

## Regras implementadas

- O pedido contém produtos com quantidade e preço unitário de venda. O total é derivado, sem coluna de subtotal armazenada.
- Um pedido gera um cupom. Várias tentativas podem dividir sua conta. Apenas Aprovados compõem o valor pago; Recusados e Estornados ficam no histórico e são excluídos da soma.
- Quitação exige igualdade exata. Valor excedente é uma divergência que bloqueia preparo. Uma recusa não cancela o pedido nem desfaz pagamentos aprovados.
- O preparo segue RECEBIDO → EM_PREPARO → PRONTO → ENTREGUE, com quitação e baixa exigidas para avançar. O cancelamento proposto é permitido antes da entrega.
- A primeira quitação baixa o estoque uma única vez. Falta de saldo aborta toda a operação local de aprovação/criação. Pagamento parcial ou recusado não baixa unidades.
- Antes do preparo, cancelar devolve as unidades baixadas. Depois do preparo, apenas retorno físico confirmado por produto recompõe o saldo. Estorno financeiro não devolve produto automaticamente.
- Recebimentos aumentam o saldo. A08 confere recebimentos menos baixas ainda não devolvidas. O saldo materializado exige restrição de escrita direta na aplicação futura.
- Os nomes de comanda são opcionais, independem de cliente cadastrado e utilizam id_pedido como alternativa de identificação. A origem admite totem, balcão e delivery; equipamento é condicional ao totem.

## Massa fictícia e resultados

| Tabela | Linhas |
|---|---:|
| cliente | 20 |
| funcionario | 6 |
| produto | 12 |
| fornecedor | 2 |
| pedido | 120 |
| pedido_produto | 270 |
| cupom_fiscal | 120 |
| pagamento | 165 |
| entrada_estoque | 3 |
| entrada_produto | 14 |

São registros pedagógicos, sem dados reais de clientes. Os 120 pedidos cobrem julho a setembro de 2026; não representam a quantidade real vendida pela unidade.

G01 retornou 33, 33 e 32 pedidos quitados, respectivamente, com R$1.437,00, R$1.428,50 e R$1.395,50. A04 identifica intencionalmente o pedido 120: total R$47,00 e aprovados R$47,01. Ele permanece bloqueado para preparo. As outras auditorias não apontam inconsistências na massa original, inclusive A08.

Os relatórios agrupam o estado atual pela data do pedido. Não há datas de estorno, cancelamento ou retorno físico suficientes para reconstruir um fechamento imutável ou estoque passado. Esse limite está registrado no README, no HTML e no guia, sem alegar uma função que o modelo não oferece.

## Conferências realizadas e limites

- Script e testes executados em dois schemas vazios separados; a validação final também retornou 31 PASS. Consulte [saída das consultas](resultado_execucao_sql.txt), [contagens](contagens_banco.txt) e [SQLSTATE dos testes](resultado_testes.txt).
- Conceitual e lógico reabertos com o motor oficial brModelo 3, sem referências ou pontas de ligação quebradas. Imagens e PDF atual inspecionados visualmente.
- HTML aberto em navegador invisível: dez tabelas e 44 colunas, com nomes/tipos/PK/FK/NULL correspondentes ao SQL; logo carregado, busca funcional e nenhum erro de JavaScript observado.
- PPTX conferido estruturalmente: oito slides, notas, tabelas nativas e fonte Arial, sem defeitos apontados pelos verificadores de pacote e geometria. A prévia proporcional em HTML dos elementos do PPTX foi inspecionada nos oito slides; três textos foram ajustados e a nova prévia não apresentou transbordamentos.
- Não houve conferência nativa no PowerPoint, conforme preferência do usuário. O renderizador de slides e o conversor alternativo falharam no ambiente. A prévia HTML não garante equivalência de renderização em outro apresentador; o ensaio no equipamento final continua necessário.
- Documentos fictícios não implementam validação completa de dígitos verificadores. Emissão fiscal oficial, adquirente, autenticação e permissões de produção não estão implementados. As operações financeiras externas exigem conciliação caso falhem localmente.

## O que o grupo ainda precisa fazer

1. **Completar o levantamento:** informar data e participantes, anexar material e comprovação da entrevista no local. A foto disponível comprova presença junto à unidade.
2. **Confirmar volumes reais:** pedidos/dia ou mês, produtos, clientes e recebimentos. Ajustar a massa ou justificar o recorte com esses números; os 120 pedidos atuais foram escolhidos para cobertura de cenários.
3. **Validar o escopo:** confirmar todos os processos da organização e registrar o tratamento de compras, contas a pagar, ingredientes, perdas, inventário, pessoal e integrações, quando existirem.
4. **Homologar as regras propostas:** momento da baixa, mínimos, cancelamento antes/depois do preparo, retorno físico, estorno, valor excedente e possibilidade de cupom sem tentativa. Atualizar DER, SQL, HTML e testes em conjunto se as decisões mudarem.
5. **Confirmar a necessidade de histórico temporal:** se houver fechamento imutável ou estoque retroativo, projetar eventos com datas; não tratar as views atuais como histórico completo.
6. **Anexar a correção oficial da Entrega 1:** completar a tabela de correspondência no README com cada apontamento do professor.
7. **Completar dados acadêmicos:** usuários GitHub dos integrantes e comparação do HTML com o PDF-exemplo do professor, ainda não disponibilizado.
8. **Definir metas técnicas e acesso:** perfis, privilégios mínimos, resposta, concorrência, disponibilidade e tratamento de falhas externas antes de uso real.
9. **Revisar e ensaiar a defesa:** conferir os slides no equipamento final, preparar as mesmas consultas do script e ensaiar os oito minutos. Todos devem compreender as restrições e estar presentes. Manter contribuições reais e identificáveis no GitHub, sem fabricar autoria.

Os códigos PV01–PV09 no [README](../README.md) detalham essas pendências. Nenhum teste técnico substitui a confirmação das informações reais.

## Como executar

1. Abra uma instalação MySQL 8.0.16 ou superior com um ambiente de demonstração vazio.
2. Na raiz do projeto e dentro do cliente mysql, execute SOURCE docs/script.sql; e depois SOURCE docs/testes_integridade.sql;.
3. Confira 31 PASS, G01 e as auditorias. A04 deve retornar a divergência intencional; A08 deve retornar vazio.
4. Abra index.html no navegador e os arquivos .brM3 no brModelo 3. Para apresentar, siga o roteiro.
5. Consulte o [guia de execução](execucao_mysql.md) antes de repetir a carga. O script não apaga automaticamente um banco existente e não deve ser forçado sobre uma base com o mesmo nome.

O email de conclusão acompanha este relatório e um pacote dos arquivos da entrega. O identificador do commit e a situação do envio ao GitHub serão informados no próprio email, após a conferência final.
