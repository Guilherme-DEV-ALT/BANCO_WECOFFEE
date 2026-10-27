# Validação técnica da Entrega 2

Data: 27/10/2026. Resultado técnico não equivale a homologação pela organização nem resolve as pendências de campo do README.

## Banco de dados

- MySQL Community Server 8.4.13 portátil, em pasta temporária fora do projeto; servidor limitado a 127.0.0.1, porta 33307, sem serviço permanente.
- Pacote oficial: mysql-8.4.13-winx64.zip. MD5 obtido: 7b94489d5524dea9b27097068bea25a8, igual ao publicado na página oficial de download consultada.
- Script completo executado em banco vazio, com criação de dez tabelas, views, rotinas e triggers e carga fictícia.
- 31 testes passaram. O [resultado original](resultado_testes.txt) registra a versão e o SQLSTATE real das rejeições.

| Verificação | Resultado observado |
|---|---|
| Quantidades inteiras, preços positivos e centavos | Rejeições confirmadas para zero, fração de quantidade e fração de centavo. |
| FK, documento duplicado e origem condicional | Rejeições confirmadas. |
| Preparo sem quitação e alteração de preço histórico | Operações rejeitadas. |
| Baixa sem saldo | Operação rejeitada; criação do pedido revertida integralmente. |
| Recusa e estorno | Não compõem o valor pago. |
| Cancelamento antes/depois do preparo | Antes: unidades devolvidas; depois: consumo preservado até retorno físico confirmado. |
| Quitação e nova recusa | Primeira quitação baixa a quantidade exata; nova recusa não repete a baixa. |
| Divergência | Pedido 120: R$47,00 de total e R$47,01 aprovado, identificado por A04. |
| Relatórios | G01: R$1.437,00, R$1.428,50 e R$1.395,50; resultados fictícios. |
| Estoque materializado | Auditoria A08 sem divergências na massa original. |

## Reprodutibilidade

Consultar [execucao_mysql.md](execucao_mysql.md). O script não apaga automaticamente um banco existente. O registro dos testes corresponde à execução real; não é uma expectativa não executada. Novos testes devem preservar a massa ou ser feitos em uma cópia de demonstração.

## Conferências dos demais artefatos

Os tipos e chaves do dicionário e do modelo lógico são derivados das definições do script. A entrega deve manter dez tabelas, 44 colunas, nove FKs e duas PKs compostas nas tabelas de ligação. O conceitual possui oito entidades, sete relacionamentos e 36 atributos, sem FKs. O relatório de conclusão registra as conferências finais de links, arquivos nativos, imagens, PDF e apresentação.

## Pendências que os testes não resolvem

Data e participantes da entrevista, foto específica, volumes reais, identidades GitHub, correção oficial da E1, cobertura integral dos processos da organização, momento real da baixa, estágios de cancelamento, procedimento fiscal, primeira tentativa e metas técnicas. Os 120 pedidos são uma carga pedagógica; não uma medição da loja. O HTML ainda deve ser confrontado pelo grupo com o PDF-exemplo do professor, não disponibilizado nesta conversa.

## Reabertura dos arquivos nativos

O DER foi reaberto no motor brModelo 3: oito entidades, sete relacionamentos, 36 atributos e 50 ligações, sem pontas quebradas. O lógico foi reaberto com dez tabelas, 44 campos, nove FKs e nove ligações, sem referências quebradas. Os tipos e a estrutura do SVG foram conferidos visualmente. O PDF atual da Entrega 2 foi renderizado e inspecionado; a versão anterior na raiz permanece preservada.

## Dicionário e apresentação

HTML conferido em navegador invisível: dez tabelas e 44 colunas correspondentes em nome, tipo, PK/FK e NULL, busca funcional e logo carregado, sem erros de JavaScript. PPTX: oito slides, fonte Arial, verificadores de pacote e geometria sem achados. Os oito slides tiveram prévia proporcional em HTML inspecionada; após três ajustes de texto, não houve transbordamento nessa prévia. Não houve renderização nativa no PowerPoint, por preferência do usuário, nem sucesso dos renderizadores alternativos no ambiente. A prévia não comprova equivalência entre apresentadores; conferir e ensaiar no equipamento final.
