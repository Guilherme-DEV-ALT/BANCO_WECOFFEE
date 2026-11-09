-- Levantamento: entrevista com o auxiliar geral em 08/11/2026, relatada em 09/11/2026.
-- RN33: fechamento ao final de cada dia, exclusivamente por gerentes (confirmado).
-- RN23/RN24: cancelamento da nota/pedido e estorno imediato pelo cartão,
-- com balanceamento automático no sistema existente (confirmados pelo relato).
-- Este SQL não executa integrações fiscais/de cartão nem registra fechamentos.
-- Recorte auxiliar de docs/script.sql. Execute primeiro o script completo.
-- Consulta de um dia civil: @inicio no início do dia e @fim no início do seguinte.
-- Essa é a convenção analítica do projeto; o corte exato da unidade não foi informado.
-- Consultar não efetiva fechamento: autenticação e registro gerencial não implementados.
SET @inicio = '2026-10-01 00:00:00';
SET @fim = '2026-11-01 00:00:00';

-- G01 — Qual é o valor mensal das vendas quitadas e o ticket médio por canal?
-- Atende: P1; K01; K02
-- Cada fonte é agregada antes do JOIN para evitar multiplicação de valores.
WITH itens AS (
    SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
    FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
    SELECT id_cupom_fiscal,
           SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
    FROM PAGAMENTO GROUP BY id_cupom_fiscal
)
SELECT DATE_FORMAT(p.data_hora, '%Y-%m') AS mes, p.origem_pedido,
       COUNT(*) AS pedidos_quitados, SUM(i.total) AS valor_vendas_quitadas,
       AVG(i.total) AS ticket_medio
FROM PEDIDO p
JOIN itens i ON i.id_pedido = p.id_pedido
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
JOIN pagos pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE p.data_hora >= @inicio AND p.data_hora < @fim
  AND p.status_preparo <> 'CANCELADO' AND pg.pago = i.total
GROUP BY DATE_FORMAT(p.data_hora, '%Y-%m'), p.origem_pedido;

-- G02 — Quais produtos lideram em unidades e participação no valor vendido?
-- Atende: K03; P2 apenas como apoio à demanda, sem medir ruptura
WITH totais AS (
    SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
    FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
    SELECT id_cupom_fiscal,
           SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
    FROM PAGAMENTO GROUP BY id_cupom_fiscal
), vendas AS (
    SELECT pr.id_produto, pr.nome, SUM(i.quantidade) AS unidades,
           SUM(i.quantidade * i.preco_unitario) AS valor_vendido
    FROM PEDIDO p
    JOIN totais t ON t.id_pedido = p.id_pedido
    JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
    JOIN pagos pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
    JOIN ITEM_PEDIDO i ON i.id_pedido = p.id_pedido
    JOIN PRODUTO pr ON pr.id_produto = i.id_produto
    WHERE p.data_hora >= @inicio AND p.data_hora < @fim
      AND p.status_preparo <> 'CANCELADO' AND pg.pago = t.total
    GROUP BY pr.id_produto, pr.nome
)
SELECT *, 100.0 * valor_vendido / NULLIF(SUM(valor_vendido) OVER (), 0) AS participacao_percentual
FROM vendas ORDER BY valor_vendido DESC;

-- G03 — Qual a taxa de recusa e os valores por forma de pagamento?
-- Situação atual por data da tentativa; sem evento/data de estorno, não reconstrói
-- fluxo de devoluções nem fechamento histórico, mesmo com estorno imediato relatado.
-- Atende: K04; K05
-- Período definido pela data da tentativa, não pela data do pedido.
SELECT forma_pagamento, COUNT(*) AS tentativas,
       100.0 * SUM(CASE WHEN status_pagamento = 'Recusado' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0) AS taxa_recusa_percentual,
       SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS valor_aprovado_atual,
       SUM(CASE WHEN status_pagamento = 'Estornado' THEN valor_pagamento ELSE 0 END) AS valor_estornado_atual
FROM PAGAMENTO
WHERE data_hora_pagamento >= @inicio AND data_hora_pagamento < @fim
GROUP BY forma_pagamento;

-- G04 — Quais pedidos têm pendências, divergências ou devoluções pendentes?
-- Atende: P1; K06
-- Inclui pedidos sem itens, cupom ou pagamentos para evidenciar inconsistências.
WITH itens AS (
    SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
    FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
    SELECT id_cupom_fiscal, COUNT(*) AS tentativas,
           SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
    FROM PAGAMENTO GROUP BY id_cupom_fiscal
)
SELECT p.id_pedido, i.total, COALESCE(pg.pago, 0) AS valor_pago,
       CASE
         WHEN i.id_pedido IS NULL THEN 'SEM_ITENS'
         WHEN c.id_cupom_fiscal IS NULL THEN 'SEM_CUPOM'
         WHEN pg.id_cupom_fiscal IS NULL THEN 'SEM_TENTATIVA'
         WHEN p.status_preparo = 'CANCELADO' AND COALESCE(pg.pago, 0) > 0 THEN 'DEVOLUCAO_PENDENTE'
         WHEN p.status_preparo = 'CANCELADO' THEN 'CANCELADO_SEM_DEVOLUCAO_PENDENTE'
         WHEN pg.pago = i.total THEN 'QUITADO'
         WHEN pg.pago > i.total THEN 'DIVERGENCIA'
         ELSE 'PENDENTE'
       END AS situacao
FROM PEDIDO p
LEFT JOIN itens i ON i.id_pedido = p.id_pedido
LEFT JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
LEFT JOIN pagos pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE p.data_hora >= @inicio AND p.data_hora < @fim;

-- G05 — Quais dias, horários e canais concentram pedidos?
-- Atende: K07
-- Inclui pedidos ainda não quitados; mede demanda registrada, não vendas pagas.
SELECT WEEKDAY(data_hora) AS dia_semana_segunda_zero,
       HOUR(data_hora) AS hora, origem_pedido, COUNT(*) AS pedidos_registrados
FROM PEDIDO
WHERE data_hora >= @inicio AND data_hora < @fim AND status_preparo <> 'CANCELADO'
GROUP BY WEEKDAY(data_hora), HOUR(data_hora), origem_pedido;

-- G06 — Qual a frequência e o valor de compras por cliente identificado?
-- Atende: K08
WITH itens AS (
    SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
    FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
    SELECT id_cupom_fiscal,
           SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
    FROM PAGAMENTO GROUP BY id_cupom_fiscal
)
SELECT p.id_cliente, COUNT(*) AS compras, MAX(p.data_hora) AS ultima_compra_no_periodo,
       SUM(i.total) AS valor_compras
FROM PEDIDO p
JOIN itens i ON i.id_pedido = p.id_pedido
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
JOIN pagos pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE p.id_cliente IS NOT NULL AND p.status_preparo <> 'CANCELADO'
  AND p.data_hora >= @inicio AND p.data_hora < @fim AND pg.pago = i.total
GROUP BY p.id_cliente;

-- G07 — Qual a taxa de cancelamento por canal?
-- Atende: K09
SELECT origem_pedido, COUNT(*) AS pedidos,
       SUM(CASE WHEN status_preparo = 'CANCELADO' THEN 1 ELSE 0 END) AS cancelados,
       100.0 * SUM(CASE WHEN status_preparo = 'CANCELADO' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0) AS taxa_cancelamento_percentual
FROM PEDIDO
WHERE data_hora >= @inicio AND data_hora < @fim
GROUP BY origem_pedido;

-- G08 — Quais produtos estão sem saldo ou no limite de reposição agora?
-- Atende: P2 (ruptura e disponibilidade); K10 (saldo e disponibilidade); K11 (reposição).
-- Saldo atual, sem filtro mensal; não afirma atualização dos canais externos.
SELECT pr.id_produto,pr.nome,e.quantidade_disponivel,e.estoque_minimo,
 CASE WHEN e.quantidade_disponivel=0 THEN 'INDISPONIVEL' ELSE 'DISPONIVEL' END AS disponibilidade,
 CASE WHEN e.quantidade_disponivel<=e.estoque_minimo THEN 'REPOR' ELSE 'REGULAR' END AS reposicao
FROM PRODUTO pr JOIN ESTOQUE e ON e.id_produto=pr.id_produto
ORDER BY e.quantidade_disponivel,pr.id_produto;

-- G09 — Qual a quantidade movimentada por produto e tipo no período?
-- Atende: P2; K12 (entradas, consumo, perdas e ajustes por produto).
-- Fluxo pelo horário da movimentação; não calcula custo ou valor de desperdício.
SELECT pr.id_produto,pr.nome,m.tipo,SUM(m.quantidade) AS unidades
FROM MOVIMENTACAO_ESTOQUE m JOIN PRODUTO pr ON pr.id_produto=m.id_produto
WHERE m.data_hora>=@inicio AND m.data_hora<@fim
GROUP BY pr.id_produto,pr.nome,m.tipo ORDER BY pr.id_produto,m.tipo;
