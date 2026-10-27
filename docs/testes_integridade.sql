-- Testes significativos de integridade para MySQL 8.0.16+.
-- Executar DEPOIS de script.sql em uma instancia de demonstracao.
USE wecoffee_entrega2_demo;
DROP PROCEDURE IF EXISTS sp_teste_assert;
DROP PROCEDURE IF EXISTS sp_teste_rejeicao;
CREATE TEMPORARY TABLE resultados_teste(nome VARCHAR(120),resultado VARCHAR(10),detalhe VARCHAR(255)) ENGINE=MEMORY;
DELIMITER $$
CREATE PROCEDURE sp_teste_assert(IN p_nome VARCHAR(120),IN p_condicao BOOLEAN)
BEGIN
 IF p_condicao IS NULL OR NOT p_condicao THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falha em assercao de integridade'; END IF;
 INSERT INTO resultados_teste VALUES(p_nome,'PASS','Condicao esperada confirmada');
END$$
CREATE PROCEDURE sp_teste_rejeicao(IN p_nome VARCHAR(120),IN p_sql TEXT,IN p_estado CHAR(5))
BEGIN
 DECLARE v_falhou BOOLEAN DEFAULT FALSE; DECLARE v_estado CHAR(5); DECLARE v_mensagem TEXT;
 SET @sql_teste=p_sql;
 PREPARE comando_teste FROM @sql_teste;
 BEGIN
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   BEGIN GET STACKED DIAGNOSTICS CONDITION 1 v_estado=RETURNED_SQLSTATE,v_mensagem=MESSAGE_TEXT; SET v_falhou=TRUE; END;
   EXECUTE comando_teste;
 END;
 DEALLOCATE PREPARE comando_teste;
 IF NOT v_falhou OR v_estado IS NULL OR v_estado<>p_estado THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Operacao invalida nao foi rejeitada como esperado'; END IF;
 INSERT INTO resultados_teste VALUES(p_nome,'PASS',CONCAT(v_estado,': ',LEFT(v_mensagem,220)));
END$$
DELIMITER ;
CALL sp_teste_rejeicao('T01 preco zero', 'INSERT INTO produto(nome,preco) VALUES(''Teste invalido'',0)','HY000');
CALL sp_teste_rejeicao('T02 nome vazio', 'INSERT INTO produto(nome,preco) VALUES('''',1)','HY000');
CALL sp_teste_rejeicao('T03 documento duplicado', 'INSERT INTO cliente(nome,cpf_cnpj) VALUES(''Duplicado'',''00000000001'')','23000');
CALL sp_teste_rejeicao('T04 cliente inexistente', 'INSERT INTO pedido(id_cliente,origem_pedido) VALUES(999999,''D'')','23000');
CALL sp_teste_rejeicao('T05 totem ausente', 'INSERT INTO pedido(origem_pedido) VALUES(''T'')','HY000');
CALL sp_teste_rejeicao('T06 balcao sem funcionario', 'INSERT INTO pedido(origem_pedido) VALUES(''B'')','HY000');
CALL sp_teste_rejeicao('T07 pedido sem produtos', 'CALL sp_criar_pedido(NULL,NULL,''D'',NULL,NULL,''2026-09-30'',''TESTE-SEM-ITEM'',JSON_ARRAY(),JSON_ARRAY(JSON_OBJECT(''forma_pagamento'',''P'',''valor_pagamento'',1,''status_pagamento'',''R'')),@teste_pedido)','45000');
CALL sp_teste_rejeicao('T08 quantidade fracionaria', 'CALL sp_criar_pedido(NULL,NULL,''D'',NULL,NULL,''2026-09-30'',''TESTE-FRACAO'',JSON_ARRAY(JSON_OBJECT(''id_produto'',1,''quantidade'',1.25,''preco_unitario'',1)),JSON_ARRAY(JSON_OBJECT(''forma_pagamento'',''P'',''valor_pagamento'',1,''status_pagamento'',''R'')),@teste_pedido)','45000');
CALL sp_teste_rejeicao('T09 preco com fracao de centavo', 'CALL sp_criar_pedido(NULL,NULL,''D'',NULL,NULL,''2026-09-30'',''TESTE-CENTAVO'',JSON_ARRAY(JSON_OBJECT(''id_produto'',1,''quantidade'',1,''preco_unitario'',1.001)),JSON_ARRAY(JSON_OBJECT(''forma_pagamento'',''P'',''valor_pagamento'',1,''status_pagamento'',''R'')),@teste_pedido)','45000');
CALL sp_teste_rejeicao('T10 preparo sem quitacao', 'UPDATE pedido SET status_preparo=''EM_PREPARO'' WHERE id_pedido=35','45000');
CALL sp_teste_rejeicao('T11 alteracao de preco historico', 'UPDATE pedido_produto SET preco_unitario=1 WHERE id_pedido=1 AND id_produto=1','45000');
CALL sp_teste_rejeicao('T12 exclusao de pagamento', 'DELETE FROM pagamento WHERE id_pagamento=1','45000');
CALL sp_teste_rejeicao('T13 alteracao de cupom', 'UPDATE cupom_fiscal SET numero=''ALTERADO'' WHERE id_cupom_fiscal=1','45000');
CALL sp_teste_rejeicao('T14 devolucao acima do vendido', 'UPDATE pedido_produto SET quantidade_devolvida=quantidade+1 WHERE id_pedido=39','45000');
CALL sp_teste_rejeicao('T15 estorno sem cancelamento', 'UPDATE pagamento SET status_pagamento=''E'' WHERE id_pagamento=1','45000');
SET @pedidos_antes=(SELECT COUNT(*) FROM pedido);
CALL sp_teste_rejeicao('T16 estoque insuficiente', 'CALL sp_criar_pedido(NULL,NULL,''D'',NULL,NULL,''2026-09-30'',''TESTE-SEM-SALDO'',JSON_ARRAY(JSON_OBJECT(''id_produto'',1,''quantidade'',1000000,''preco_unitario'',1)),JSON_ARRAY(JSON_OBJECT(''forma_pagamento'',''P'',''valor_pagamento'',1000000,''status_pagamento'',''A'')),@teste_pedido)','45000');
CALL sp_teste_assert('T17 rollback de pedido sem saldo',(SELECT COUNT(*) FROM pedido)=@pedidos_antes);
CALL sp_teste_rejeicao('T18 recebimento vazio', 'CALL sp_registrar_entrada(1,''2026-09-30'',JSON_ARRAY(),@teste_entrada)','45000');
CALL sp_teste_rejeicao('T19 recebimento fracionario', 'CALL sp_registrar_entrada(1,''2026-09-30'',JSON_ARRAY(JSON_OBJECT(''id_produto'',1,''quantidade_recebida'',1.2)),@teste_entrada)','45000');
CALL sp_teste_rejeicao('T20 cancelamento apos entrega', 'CALL sp_cancelar_pedido(1)','45000');
CALL sp_teste_assert('T21 recusado nao compoe valor pago',(SELECT valor_pago FROM vw_situacao_pedido WHERE id_pedido=33)=0);
CALL sp_teste_assert('T22 estornado nao compoe valor pago',(SELECT valor_pago FROM vw_situacao_pedido WHERE id_pedido=39)=0);
CALL sp_teste_assert('T23 cancelamento antes do preparo devolve tudo',(SELECT SUM(quantidade-quantidade_devolvida) FROM pedido_produto WHERE id_pedido=39)=0);
CALL sp_teste_assert('T24 cancelamento apos preparo preserva consumo',(SELECT SUM(quantidade_devolvida) FROM pedido_produto WHERE id_pedido=38)=0);
CALL sp_teste_assert('T25 divergencia intencional detectada',(SELECT COUNT(*) FROM vw_situacao_pedido WHERE situacao_financeira='DIVERGENCIA')=1);
CALL sp_teste_assert('T26 diferenca exata de um centavo',(SELECT valor_pago-valor_total FROM vw_situacao_pedido WHERE id_pedido=120)=0.01);
CALL sp_teste_assert('T27 historico preserva preco original',(SELECT preco_unitario FROM pedido_produto WHERE id_pedido=1 AND id_produto=1)=8.50);
START TRANSACTION;
SET @saldo_antes=(SELECT quantidade_disponivel FROM produto WHERE id_produto=11);
SET @qtd_esperada=(SELECT quantidade FROM pedido_produto WHERE id_pedido=35 AND id_produto=11);
SET @cupom=(SELECT id_cupom_fiscal FROM cupom_fiscal WHERE id_pedido=35);
SET @restante=(SELECT saldo_restante FROM vw_situacao_pedido WHERE id_pedido=35);
INSERT INTO pagamento(id_cupom_fiscal,forma_pagamento,valor_pagamento,status_pagamento,data_hora_pagamento) VALUES(@cupom,'P',@restante,'A','2026-09-30');
CALL sp_teste_assert('T28 quitacao baixa quantidade exata',(SELECT quantidade_disponivel FROM produto WHERE id_produto=11)=@saldo_antes-@qtd_esperada);
SET @saldo_depois=(SELECT quantidade_disponivel FROM produto WHERE id_produto=11);
INSERT INTO pagamento(id_cupom_fiscal,forma_pagamento,valor_pagamento,status_pagamento,data_hora_pagamento) VALUES(@cupom,'C',1,'R','2026-09-30');
CALL sp_teste_assert('T29 nova recusa nao repete baixa',(SELECT quantidade_disponivel FROM produto WHERE id_produto=11)=@saldo_depois);
ROLLBACK;
-- A tabela de resultados usa MEMORY para manter evidencias mesmo apos o rollback.
CALL sp_teste_assert('T30 transacao de quitacao revertida',(SELECT situacao_financeira FROM vw_situacao_pedido WHERE id_pedido=35)='PARCIAL');
CALL sp_teste_assert('T31 reversao preserva saldo',(SELECT quantidade_disponivel FROM produto WHERE id_produto=11)=@saldo_antes);
SELECT VERSION() AS versao_mysql,DATABASE() AS banco,COUNT(*) AS testes_aprovados FROM resultados_teste;
SELECT * FROM resultados_teste ORDER BY nome;
DROP PROCEDURE sp_teste_assert;
DROP PROCEDURE sp_teste_rejeicao;
