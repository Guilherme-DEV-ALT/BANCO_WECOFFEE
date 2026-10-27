# Roteiro da apresentação corporativa

Pitch planejado: **8 minutos (480 segundos)**. O ensaio, os apresentadores e as confirmações com a unidade são responsabilidade do grupo. Não declarar os dados de demonstração como faturamento real.

| Slide | Assunto | Tempo | Ação de demonstração |
|---|---|---|---|
| 1 | Contextualização do problema | 60 s | Explicar P1 e diferenciar foto de presença de comprovação da entrevista pendente. |
| 2 | Solução proposta | 55 s | Explicar pedido, cupom, pagamentos e recebimento. Informar que estoque é proposta a validar. |
| 3 | Modelo lógico | 80 s | Abrir o SVG completo e explicar as tabelas de associação e a chave composta do recorte. |
| 4 | Implementação SQL | 70 s | Mostrar execução em banco vazio e o resultado dos testes. Preparar o ambiente antes do pitch. |
| 5 | Consultas gerenciais | 70 s | Executar G01; se houver tempo, mostrar G08. Destacar a ausência de duplicação por pagamentos divididos. |
| 6 | Auditoria | 60 s | Executar A04 (uma divergência intencional) e A08 (saldo consistente, resultado vazio). |
| 7 | BI e IA | 45 s | Explicar views de leitura e possibilidade futura de previsão com histórico real. |
| 8 | Benefícios e próximos passos | 40 s | Encerrar com benefícios da proposta e pendências de homologação. |
| **Total** | | **480 s** | |

## Preparação da demonstração

1. Ter uma instalação MySQL 8.0.16+ e um schema vazio para executar docs/script.sql, conforme docs/execucao_mysql.md. Não executar por engano contra uma base existente.
2. Abrir o modelo lógico completo e manter o PowerPoint disponível. As mesmas consultas do arquivo serão usadas ao vivo.
3. Abrir docs/resultado_testes.txt como evidência alternativa se o ambiente da apresentação falhar. Não apresentar esse arquivo como substituto de um ensaio prévio.
4. Conferir que G01 retorna 33, 33 e 32 pedidos quitados, com R$1.437,00, R$1.428,50 e R$1.395,50, na massa fictícia original.
5. Explicar que os 98 quitados incluem pedidos em preparo e prontos, além dos 86 entregues. Cancelados não entram nas vendas quitadas.
6. A04 mostra o pedido 120: total R$47,00 e aprovado R$47,01. Ele não pode avançar ao preparo. A08 deve retornar vazio.
7. Ensaiar para oito minutos, com texto falado em vez de leitura de parágrafos. Todos os integrantes devem estar presentes para a defesa.

## Perguntas para a defesa individual

- Por que o conceitual mantém N:M com atributos, mas o lógico usa tabelas de associação?
- Quais atributos dependem do par em cada PK composta?
- Como a separação de cadastros evita dependências parciais e transitivas?
- Por que valor_total fica em view e o saldo é materializado? Como A08 confere a materialização?
- Como impedir duplicação de faturamento ao combinar produtos e vários pagamentos?
- Como a recusa, a quitação, o cancelamento, o estorno e o retorno físico afetam o banco?
- O que as FKs não garantem sobre a existência de linhas-filhas? Como rotinas e auditorias cobrem as mínimas?
- Quais regras são propostas e quais dados ainda faltam confirmar?
- Por que os relatórios não recompõem um fechamento antigo após estorno posterior?
- Como justificar o tamanho da massa após obter o volume real da unidade?

A defesa ocorre depois do pitch e cada pergunta deve ser respondida pelo aluno a quem for dirigida. Não há distribuição fictícia de participação ou ensaio declarado como realizado.
