-- Extensão apenas do modelo lógico/físico. O DER conceitual permanece inalterado.
-- RN25–RN32: estoque de produtos prontos, unidades inteiras.
CREATE TABLE ESTOQUE (
 id_produto INT NOT NULL PRIMARY KEY,
 quantidade_disponivel INT NOT NULL DEFAULT 0,
 estoque_minimo INT NOT NULL DEFAULT 0,
 data_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK (quantidade_disponivel >= 0),
 CHECK (estoque_minimo >= 0)
) ENGINE=InnoDB;

CREATE TABLE MOVIMENTACAO_ESTOQUE (
 id_movimentacao INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 id_produto INT NOT NULL,
 id_pedido INT NULL,
 id_funcionario INT NOT NULL,
 tipo VARCHAR(15) NOT NULL,
 quantidade INT NOT NULL,
 data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 motivo VARCHAR(255) NOT NULL,
 referencia VARCHAR(80) NOT NULL UNIQUE,
 FOREIGN KEY (id_produto) REFERENCES ESTOQUE(id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY (id_pedido,id_produto) REFERENCES ITEM_PEDIDO(id_pedido,id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_funcionario) ON DELETE RESTRICT ON UPDATE RESTRICT,
 UNIQUE (id_pedido,id_produto,tipo),
 CHECK (quantidade > 0),
 CHECK (tipo IN ('ENTRADA','VENDA','PERDA','AJUSTE_ENTRADA','AJUSTE_SAIDA','RETORNO')),
 CHECK ((tipo IN ('VENDA','RETORNO') AND id_pedido IS NOT NULL)
     OR (tipo IN ('ENTRADA','PERDA','AJUSTE_ENTRADA','AJUSTE_SAIDA') AND id_pedido IS NULL)),
 CHECK (CHAR_LENGTH(TRIM(motivo)) > 0),
 CHECK (CHAR_LENGTH(TRIM(referencia)) > 0)
) ENGINE=InnoDB;

-- Saldo materializado para permitir atualização atômica sob concorrência.
-- O livro de movimentos é a origem da conciliação; não editar saldos manualmente.
DELIMITER $$
CREATE TRIGGER tr_produto_estoque AFTER INSERT ON PRODUTO FOR EACH ROW
BEGIN
 INSERT INTO ESTOQUE(id_produto) VALUES(NEW.id_produto);
END$$

CREATE TRIGGER tr_movimentacao_inserir BEFORE INSERT ON MOVIMENTACAO_ESTOQUE FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(12);
 DECLARE v_quantidade INT;
 DECLARE v_total DECIMAL(18,2);
 DECLARE v_pago DECIMAL(18,2);
 DECLARE v_delta INT;
 -- Pedido antes de estoque: mesma ordem de bloqueio usada nas rotinas.
 IF NEW.tipo IN ('VENDA','RETORNO') THEN
   SELECT status_preparo INTO v_status FROM PEDIDO WHERE id_pedido=NEW.id_pedido FOR UPDATE;
   SELECT quantidade INTO v_quantidade FROM ITEM_PEDIDO
    WHERE id_pedido=NEW.id_pedido AND id_produto=NEW.id_produto FOR UPDATE;
   IF v_quantidade IS NULL OR NEW.quantidade <> v_quantidade THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Quantidade deve corresponder ao item integral do pedido';
   END IF;
   IF NEW.tipo='VENDA' THEN
     IF v_status <> 'RECEBIDO' THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Baixa somente antes da liberacao para preparo';
     END IF;
     SELECT SUM(quantidade*preco_unitario) INTO v_total
       FROM ITEM_PEDIDO WHERE id_pedido=NEW.id_pedido FOR UPDATE;
     SELECT COALESCE(SUM(CASE WHEN pg.status_pagamento='Aprovado' THEN pg.valor_pagamento ELSE 0 END),0)
       INTO v_pago FROM CUPOM_FISCAL c JOIN PAGAMENTO pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal
       WHERE c.id_pedido=NEW.id_pedido FOR UPDATE;
     IF v_total IS NULL OR v_total <> v_pago THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Baixa exige quitacao exata';
     END IF;
   ELSE
     IF v_status <> 'CANCELADO' THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Retorno exige pedido cancelado';
     END IF;
     IF NOT EXISTS (SELECT 1 FROM MOVIMENTACAO_ESTOQUE
       WHERE id_pedido=NEW.id_pedido AND id_produto=NEW.id_produto AND tipo='VENDA') THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Retorno exige baixa anterior';
     END IF;
   END IF;
 END IF;
 SET v_delta=CASE WHEN NEW.tipo IN ('ENTRADA','AJUSTE_ENTRADA','RETORNO')
                  THEN NEW.quantidade ELSE -NEW.quantidade END;
 UPDATE ESTOQUE SET quantidade_disponivel=quantidade_disponivel+v_delta,
                    data_atualizacao=NEW.data_hora
 WHERE id_produto=NEW.id_produto AND quantidade_disponivel+v_delta >= 0;
 IF ROW_COUNT() <> 1 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estoque inexistente ou saldo insuficiente';
 END IF;
END$$

CREATE TRIGGER tr_movimentacao_imutavel_update BEFORE UPDATE ON MOVIMENTACAO_ESTOQUE FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Movimentacao imutavel: registrar ajuste com motivo';
END$$
CREATE TRIGGER tr_movimentacao_imutavel_delete BEFORE DELETE ON MOVIMENTACAO_ESTOQUE FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Historico de estoque nao pode ser excluido';
END$$

-- Congelar composição depois da baixa evita divergência entre consumo e pedido.
CREATE TRIGGER tr_item_estoque_insert BEFORE INSERT ON ITEM_PEDIDO FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(12);
 DECLARE v_movimentos INT;
 SELECT status_preparo INTO v_status FROM PEDIDO WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 SELECT COUNT(*) INTO v_movimentos FROM MOVIMENTACAO_ESTOQUE
  WHERE id_pedido=NEW.id_pedido AND tipo='VENDA' FOR UPDATE;
 IF v_movimentos>0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pedido com baixa: composicao preservada';
 END IF;
END$$
CREATE TRIGGER tr_item_estoque_update BEFORE UPDATE ON ITEM_PEDIDO FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(12);
 DECLARE v_movimentos INT;
 SELECT status_preparo INTO v_status FROM PEDIDO WHERE id_pedido=OLD.id_pedido FOR UPDATE;
 IF NEW.id_pedido <> OLD.id_pedido OR NEW.id_produto <> OLD.id_produto THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Identificadores do item sao imutaveis';
 END IF;
 SELECT COUNT(*) INTO v_movimentos FROM MOVIMENTACAO_ESTOQUE
  WHERE id_pedido=OLD.id_pedido AND tipo='VENDA' FOR UPDATE;
 IF v_movimentos>0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pedido com baixa: item e preco historico preservados';
 END IF;
END$$
CREATE TRIGGER tr_item_estoque_delete BEFORE DELETE ON ITEM_PEDIDO FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(12);
 DECLARE v_movimentos INT;
 SELECT status_preparo INTO v_status FROM PEDIDO WHERE id_pedido=OLD.id_pedido FOR UPDATE;
 SELECT COUNT(*) INTO v_movimentos FROM MOVIMENTACAO_ESTOQUE
  WHERE id_pedido=OLD.id_pedido AND tipo='VENDA' FOR UPDATE;
 IF v_movimentos>0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pedido com baixa: item preservado';
 END IF;
END$$

CREATE TRIGGER tr_pedido_inicial BEFORE INSERT ON PEDIDO FOR EACH ROW
BEGIN
 IF NEW.status_preparo<>'RECEBIDO' THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Novo pedido deve iniciar como RECEBIDO';
 END IF;
END$$

CREATE TRIGGER tr_pedido_liberacao BEFORE UPDATE ON PEDIDO FOR EACH ROW
BEGIN
 DECLARE v_itens INT;
 DECLARE v_baixas INT;
 DECLARE v_total DECIMAL(18,2);
 DECLARE v_pago DECIMAL(18,2);
 IF NEW.status_preparo <> OLD.status_preparo THEN
   IF NOT ((OLD.status_preparo='RECEBIDO' AND NEW.status_preparo IN ('EM_PREPARO','CANCELADO'))
       OR (OLD.status_preparo='EM_PREPARO' AND NEW.status_preparo IN ('PRONTO','CANCELADO'))
       OR (OLD.status_preparo='PRONTO' AND NEW.status_preparo IN ('ENTREGUE','CANCELADO'))
       OR (OLD.status_preparo='ENTREGUE' AND NEW.status_preparo='CANCELADO')) THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transicao de preparo invalida';
   END IF;
   IF NEW.status_preparo='EM_PREPARO' THEN
     SELECT COUNT(*),SUM(quantidade*preco_unitario) INTO v_itens,v_total
       FROM ITEM_PEDIDO WHERE id_pedido=OLD.id_pedido FOR UPDATE;
     SELECT COUNT(*) INTO v_baixas FROM MOVIMENTACAO_ESTOQUE
       WHERE id_pedido=OLD.id_pedido AND tipo='VENDA';
     SELECT COALESCE(SUM(CASE WHEN pg.status_pagamento='Aprovado' THEN pg.valor_pagamento ELSE 0 END),0)
       INTO v_pago FROM CUPOM_FISCAL c JOIN PAGAMENTO pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal
       WHERE c.id_pedido=OLD.id_pedido FOR UPDATE;
     IF v_itens=0 OR v_baixas<>v_itens OR v_pago<>v_total THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Liberacao exige itens, quitacao e baixa integral';
     END IF;
   END IF;
 END IF;
END$$

CREATE PROCEDURE sp_liberar_preparo(IN p_pedido INT, IN p_responsavel INT)
BEGIN
 DECLARE v_status VARCHAR(12);
 DECLARE v_fim BOOLEAN DEFAULT FALSE;
 DECLARE v_produto INT;
 DECLARE v_quantidade INT;
 DECLARE itens CURSOR FOR SELECT id_produto,quantidade FROM ITEM_PEDIDO WHERE id_pedido=p_pedido ORDER BY id_produto;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fim=TRUE;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT status_preparo INTO v_status FROM PEDIDO WHERE id_pedido=p_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status<>'RECEBIDO' THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pedido inexistente ou ja processado';
 END IF;
 OPEN itens;
 leitura: LOOP
   FETCH itens INTO v_produto,v_quantidade;
   IF v_fim THEN LEAVE leitura; END IF;
   INSERT INTO MOVIMENTACAO_ESTOQUE(id_produto,id_pedido,id_funcionario,tipo,quantidade,motivo,referencia)
   VALUES(v_produto,p_pedido,p_responsavel,'VENDA',v_quantidade,'Liberacao de pedido quitado',
          CONCAT('VENDA:',p_pedido,':',v_produto));
 END LOOP;
 CLOSE itens;
 UPDATE PEDIDO SET status_preparo='EM_PREPARO' WHERE id_pedido=p_pedido;
 COMMIT;
END$$

CREATE PROCEDURE sp_registrar_movimentacao(IN p_produto INT, IN p_tipo VARCHAR(15),
 IN p_quantidade INT, IN p_responsavel INT, IN p_motivo VARCHAR(255), IN p_referencia VARCHAR(80))
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 IF p_tipo IS NULL OR p_tipo NOT IN ('ENTRADA','PERDA','AJUSTE_ENTRADA','AJUSTE_SAIDA') THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Tipo deve ser entrada, perda ou ajuste';
 END IF;
 START TRANSACTION;
 INSERT INTO MOVIMENTACAO_ESTOQUE(id_produto,id_funcionario,tipo,quantidade,motivo,referencia)
 VALUES(p_produto,p_responsavel,p_tipo,p_quantidade,p_motivo,p_referencia);
 COMMIT;
END$$

CREATE PROCEDURE sp_retornar_estoque(IN p_pedido INT, IN p_produto INT, IN p_responsavel INT,
 IN p_apto_revenda BOOLEAN, IN p_motivo VARCHAR(255), IN p_referencia VARCHAR(80))
BEGIN
 DECLARE v_status VARCHAR(12);
 DECLARE v_quantidade INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 IF p_apto_revenda IS NULL OR p_apto_revenda<>TRUE THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Confirmar aptidao para revenda antes do retorno';
 END IF;
 START TRANSACTION;
 SELECT status_preparo INTO v_status FROM PEDIDO WHERE id_pedido=p_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status<>'CANCELADO' THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Retorno exige cancelamento';
 END IF;
 SELECT quantidade INTO v_quantidade FROM MOVIMENTACAO_ESTOQUE
  WHERE id_pedido=p_pedido AND id_produto=p_produto AND tipo='VENDA' FOR UPDATE;
 IF v_quantidade IS NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Nao houve baixa desse produto';
 END IF;
 INSERT INTO MOVIMENTACAO_ESTOQUE(id_produto,id_pedido,id_funcionario,tipo,quantidade,motivo,referencia)
 VALUES(p_produto,p_pedido,p_responsavel,'RETORNO',v_quantidade,p_motivo,p_referencia);
 COMMIT;
END$$
DELIMITER ;

-- Rotinas são unidades transacionais completas: chamar fora de transação da aplicação.
-- Retorno integral por item, uma única vez; devoluções parciais não integram esta versão.
-- Não conceder escrita direta em ESTOQUE/MOVIMENTACAO_ESTOQUE às contas da aplicação.
