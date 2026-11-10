-- Levantamento: entrevista com o auxiliar geral em 08/11/2026, relatada em 09/11/2026.
-- RN33: fechamento ao final de cada dia, exclusivamente por gerentes (confirmado).
-- RN23/RN24: cancelamento da nota/pedido e estorno imediato pelo cartão,
-- com balanceamento automático no sistema existente (confirmados pelo relato).
-- Este SQL não executa integrações fiscais/de cartão nem registra fechamentos.
CREATE DATABASE wecoffee_academico CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs;
USE wecoffee_academico;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

SET NAMES utf8mb4;

CREATE TABLE CLIENTE (
 id_cliente INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(150) NOT NULL,
 cpf_cnpj VARCHAR(14) NULL UNIQUE,
 CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
 CHECK (cpf_cnpj IS NULL OR (CHAR_LENGTH(cpf_cnpj) IN (11,14) AND cpf_cnpj REGEXP '^[0-9]+$'))
) ENGINE=InnoDB;

CREATE TABLE FUNCIONARIO (
 id_funcionario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(150) NOT NULL,
 cargo VARCHAR(80) NOT NULL,
 CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
 CHECK (CHAR_LENGTH(TRIM(cargo)) > 0)
) ENGINE=InnoDB;

CREATE TABLE PRODUTO (
 id_produto INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(150) NOT NULL,
 preco DECIMAL(12,2) NOT NULL,
 CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
 CHECK (preco > 0)
) ENGINE=InnoDB;

CREATE TABLE PEDIDO (
 id_pedido INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 id_cliente INT NULL,
 id_funcionario INT NULL,
 totem VARCHAR(50) NULL,
 nome_comanda VARCHAR(150) NULL,
 data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 origem_pedido VARCHAR(10) NOT NULL,
 status_preparo VARCHAR(12) NOT NULL DEFAULT 'RECEBIDO',
 FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_funcionario) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK (origem_pedido IN ('TOTEM','BALCÃO','DELIVERY')),
 CHECK ((origem_pedido = 'TOTEM' AND totem IS NOT NULL AND CHAR_LENGTH(TRIM(totem)) > 0)
     OR (origem_pedido IN ('BALCÃO','DELIVERY') AND totem IS NULL)),
 CHECK (nome_comanda IS NULL OR CHAR_LENGTH(TRIM(nome_comanda)) > 0),
 CHECK (status_preparo IN ('RECEBIDO','EM_PREPARO','PRONTO','ENTREGUE','CANCELADO'))
) ENGINE=InnoDB;

CREATE TABLE ITEM_PEDIDO (
 id_pedido INT NOT NULL,
 id_produto INT NOT NULL,
 quantidade INT NOT NULL,
 preco_unitario DECIMAL(12,2) NOT NULL,
 PRIMARY KEY (id_pedido,id_produto),
 FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK (quantidade > 0),
 -- Decisao tecnica: esta versao registra vendas com preco positivo; cortesias fora do escopo.
 CHECK (preco_unitario > 0)
) ENGINE=InnoDB;

CREATE TABLE CUPOM_FISCAL (
 id_cupom_fiscal INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 id_pedido INT NOT NULL UNIQUE,
 numero VARCHAR(50) NOT NULL UNIQUE,
 data_hora_emissao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK (CHAR_LENGTH(TRIM(numero)) > 0)
) ENGINE=InnoDB;

CREATE TABLE PAGAMENTO (
 id_pagamento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 id_cupom_fiscal INT NOT NULL,
 forma_pagamento VARCHAR(10) NOT NULL,
 valor_pagamento DECIMAL(12,2) NOT NULL,
 status_pagamento VARCHAR(10) NOT NULL,
 data_hora_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_cupom_fiscal) REFERENCES CUPOM_FISCAL(id_cupom_fiscal) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK (forma_pagamento IN ('PIX','Crédito','Débito','Dinheiro')),
 CHECK (valor_pagamento > 0),
 CHECK (status_pagamento IN ('Aprovado','Recusado','Estornado'))
) ENGINE=InnoDB;

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

-- 4. CARGA FICTÍCIA: não representa vendas ou pessoas reais.
START TRANSACTION;
INSERT INTO CLIENTE (id_cliente, nome, cpf_cnpj) VALUES
(1, 'Cliente Alfa', NULL),
(2, 'Cliente Beta', NULL),
(3, 'Cliente Gama', NULL),
(4, 'Cliente Delta', NULL),
(5, 'Cliente Épsilon', NULL);

INSERT INTO FUNCIONARIO (id_funcionario, nome, cargo) VALUES
(1, 'Pessoa Alfa', 'Atendente'),
(2, 'Pessoa Beta', 'Atendente'),
(3, 'Pessoa Gama', 'Barista'),
(4, 'Pessoa Delta', 'Barista'),
(5, 'Pessoa Épsilon', 'Gerente');

INSERT INTO PRODUTO (id_produto, nome, preco) VALUES
(1, 'Café espresso', 10),
(2, 'Cappuccino', 18),
(3, 'Chá gelado', 15),
(4, 'Croissant', 16),
(5, 'Cookie', 12),
(6, 'Bolo de chocolate', 20),
(7, 'Pão de queijo', 8),
(8, 'Produto temporário de demonstração', 5);

INSERT INTO PEDIDO (id_pedido, id_cliente, id_funcionario, totem, nome_comanda, data_hora, origem_pedido, status_preparo) VALUES
(1, 2, NULL, 'T01', 'Comanda 1', '2026-10-01 10:00:00', 'TOTEM', 'RECEBIDO'),
(2, 3, 1, NULL, 'Comanda 2', '2026-10-02 11:00:00', 'BALCÃO', 'RECEBIDO'),
(3, 4, NULL, NULL, NULL, '2026-10-03 12:00:00', 'DELIVERY', 'RECEBIDO'),
(4, NULL, NULL, 'T01', 'Comanda 4', '2026-10-04 13:00:00', 'TOTEM', 'RECEBIDO'),
(5, 1, NULL, NULL, 'Comanda 5', '2026-10-05 14:00:00', 'BALCÃO', 'RECEBIDO'),
(6, 2, NULL, NULL, NULL, '2026-10-06 15:00:00', 'DELIVERY', 'RECEBIDO'),
(7, 3, NULL, 'T01', 'Comanda 7', '2026-10-07 16:00:00', 'TOTEM', 'RECEBIDO'),
(8, NULL, 1, NULL, 'Comanda 8', '2026-10-08 17:00:00', 'BALCÃO', 'RECEBIDO'),
(9, 5, NULL, NULL, NULL, '2026-10-09 09:00:00', 'DELIVERY', 'RECEBIDO'),
(10, 1, NULL, 'T01', 'Comanda 10', '2026-10-10 10:00:00', 'TOTEM', 'RECEBIDO'),
(11, 2, NULL, NULL, 'Comanda 11', '2026-10-11 11:00:00', 'BALCÃO', 'RECEBIDO'),
(12, NULL, NULL, NULL, NULL, '2026-10-12 12:00:00', 'DELIVERY', 'RECEBIDO'),
(13, 4, NULL, 'T01', 'Comanda 13', '2026-10-13 13:00:00', 'TOTEM', 'RECEBIDO'),
(14, 5, 1, NULL, 'Comanda 14', '2026-10-14 14:00:00', 'BALCÃO', 'RECEBIDO'),
(15, 1, NULL, NULL, NULL, '2026-10-15 15:00:00', 'DELIVERY', 'RECEBIDO');

INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 10),
(1, 2, 2, 18),
(2, 2, 1, 18),
(2, 3, 2, 15),
(3, 3, 1, 15),
(3, 4, 2, 16),
(4, 4, 1, 16),
(4, 5, 2, 12),
(5, 5, 1, 12),
(5, 6, 2, 20),
(6, 6, 1, 20),
(6, 7, 2, 8),
(7, 7, 1, 8),
(7, 1, 2, 10),
(8, 1, 1, 10),
(8, 2, 2, 18),
(9, 2, 1, 18),
(9, 3, 2, 15),
(10, 3, 1, 15),
(10, 4, 2, 16),
(11, 4, 1, 16),
(11, 5, 2, 12),
(12, 5, 1, 12),
(12, 6, 2, 20),
(13, 6, 1, 20),
(13, 7, 2, 8),
(14, 7, 1, 8),
(14, 1, 2, 10),
(15, 1, 1, 10),
(15, 2, 2, 18);

INSERT INTO CUPOM_FISCAL (id_cupom_fiscal, id_pedido, numero, data_hora_emissao) VALUES
(1, 1, 'SIM-2026-0001', '2026-10-01 10:00:00'),
(2, 2, 'SIM-2026-0002', '2026-10-02 11:00:00'),
(3, 3, 'SIM-2026-0003', '2026-10-03 12:00:00'),
(4, 4, 'SIM-2026-0004', '2026-10-04 13:00:00'),
(5, 5, 'SIM-2026-0005', '2026-10-05 14:00:00'),
(6, 6, 'SIM-2026-0006', '2026-10-06 15:00:00'),
(7, 7, 'SIM-2026-0007', '2026-10-07 16:00:00'),
(8, 8, 'SIM-2026-0008', '2026-10-08 17:00:00'),
(9, 9, 'SIM-2026-0009', '2026-10-09 09:00:00'),
(10, 10, 'SIM-2026-0010', '2026-10-10 10:00:00'),
(11, 11, 'SIM-2026-0011', '2026-10-11 11:00:00'),
(12, 12, 'SIM-2026-0012', '2026-10-12 12:00:00'),
(13, 13, 'SIM-2026-0013', '2026-10-13 13:00:00'),
(14, 14, 'SIM-2026-0014', '2026-10-14 14:00:00'),
(15, 15, 'SIM-2026-0015', '2026-10-15 15:00:00');

INSERT INTO PAGAMENTO (id_pagamento, id_cupom_fiscal, forma_pagamento, valor_pagamento, status_pagamento, data_hora_pagamento) VALUES
(1, 1, 'Crédito', 46, 'Aprovado', '2026-10-01 10:00:00'),
(2, 2, 'Crédito', 48, 'Recusado', '2026-10-02 11:00:00'),
(3, 2, 'PIX', 48, 'Aprovado', '2026-10-02 11:00:00'),
(4, 3, 'PIX', 10, 'Aprovado', '2026-10-03 12:00:00'),
(5, 3, 'Débito', 37, 'Aprovado', '2026-10-03 12:00:00'),
(6, 4, 'PIX', 40, 'Aprovado', '2026-10-04 13:00:00'),
(7, 5, 'Crédito', 52, 'Recusado', '2026-10-05 14:00:00'),
(8, 6, 'PIX', 10, 'Aprovado', '2026-10-06 15:00:00'),
(9, 7, 'Dinheiro', 33, 'Aprovado', '2026-10-07 16:00:00'),
(10, 8, 'PIX', 46, 'Aprovado', '2026-10-08 17:00:00'),
(11, 9, 'Crédito', 48, 'Aprovado', '2026-10-09 09:00:00'),
(12, 10, 'Débito', 47, 'Aprovado', '2026-10-10 10:00:00'),
(13, 11, 'Débito', 40, 'Recusado', '2026-10-11 11:00:00'),
(14, 12, 'PIX', 52, 'Aprovado', '2026-10-12 12:00:00'),
(15, 13, 'Crédito', 36, 'Aprovado', '2026-10-13 13:00:00'),
(16, 14, 'Débito', 28, 'Aprovado', '2026-10-14 14:00:00'),
(17, 15, 'Dinheiro', 46, 'Aprovado', '2026-10-15 15:00:00');

-- Entradas iniciais fictícias; saldo inicia em zero pelo trigger do produto.
UPDATE ESTOQUE SET estoque_minimo=5;
INSERT INTO MOVIMENTACAO_ESTOQUE(id_produto,id_funcionario,tipo,quantidade,data_hora,motivo,referencia) VALUES
(1,5,'ENTRADA',50,'2026-10-01 07:00:00','Recebimento diário simulado','REC:1'),
(2,5,'ENTRADA',50,'2026-10-01 07:00:00','Recebimento diário simulado','REC:2'),
(3,5,'ENTRADA',50,'2026-10-01 07:00:00','Recebimento diário simulado','REC:3'),
(4,5,'ENTRADA',50,'2026-10-01 07:00:00','Recebimento diário simulado','REC:4'),
(5,5,'ENTRADA',50,'2026-10-01 07:00:00','Recebimento diário simulado','REC:5'),
(6,5,'ENTRADA',6,'2026-10-01 07:00:00','Recebimento diário simulado','REC:6'),
(7,5,'ENTRADA',3,'2026-10-01 07:00:00','Recebimento diário simulado','REC:7');
COMMIT;

-- Relógio da sessão fixado para a demonstração fictícia de outubro.
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 08:00:00');
-- Rotinas abaixo são chamadas fora da transação da carga.
CALL sp_liberar_preparo(1,5);
CALL sp_liberar_preparo(2,5);
CALL sp_liberar_preparo(3,5);
CALL sp_liberar_preparo(4,5);
CALL sp_liberar_preparo(8,5);
CALL sp_liberar_preparo(10,5);
CALL sp_liberar_preparo(12,5);
CALL sp_liberar_preparo(13,5);
CALL sp_liberar_preparo(14,5);
CALL sp_liberar_preparo(15,5);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido IN (1,2,4,10,12,13,15);
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido IN (1,4,10,12,15);
-- Pedido 8 cancelado depois da baixa: somente o produto 1 foi conferido para revenda.
UPDATE PEDIDO SET status_preparo='CANCELADO' WHERE id_pedido IN (8,9);
UPDATE PAGAMENTO SET status_pagamento='Estornado' WHERE id_cupom_fiscal=8;
CALL sp_retornar_estoque(8,1,5,TRUE,'Produto intacto e apto para revenda','RET:8:1');
CALL sp_registrar_movimentacao(5,'PERDA',1,5,'Produto danificado na conferência','PERDA:1');
CALL sp_registrar_movimentacao(3,'AJUSTE_ENTRADA',2,5,'Diferença positiva na contagem física','AJUSTE:1');
CALL sp_registrar_movimentacao(4,'AJUSTE_SAIDA',1,5,'Diferença negativa na contagem física','AJUSTE:2');
SET TIMESTAMP = 0;

-- 4.2 MASSA COMPLEMENTAR: amostra fictícia em setembro e outubro.
-- Não representa volume mensal real nem transações reais da unidade.
START TRANSACTION;
INSERT INTO CLIENTE (id_cliente, nome, cpf_cnpj) VALUES
(6, 'Cliente fictício 06', NULL),
(7, 'Cliente fictício 07', NULL),
(8, 'Cliente fictício 08', NULL),
(9, 'Cliente fictício 09', NULL),
(10, 'Cliente fictício 10', NULL),
(11, 'Cliente fictício 11', NULL),
(12, 'Cliente fictício 12', NULL),
(13, 'Cliente fictício 13', NULL),
(14, 'Cliente fictício 14', NULL),
(15, 'Cliente fictício 15', NULL),
(16, 'Cliente fictício 16', NULL),
(17, 'Cliente fictício 17', NULL),
(18, 'Cliente fictício 18', NULL),
(19, 'Cliente fictício 19', NULL),
(20, 'Cliente fictício 20', NULL);

INSERT INTO FUNCIONARIO (id_funcionario, nome, cargo) VALUES
(6, 'Pessoa Zeta', 'Atendente'),
(7, 'Pessoa Eta', 'Barista'),
(8, 'Pessoa Teta', 'Atendente');

INSERT INTO PRODUTO (id_produto, nome, preco) VALUES
(9, 'Latte de baunilha', 22),
(10, 'Chocolate quente', 19),
(11, 'Chá de frutas', 14),
(12, 'Sanduíche de queijo', 24),
(13, 'Biscoito amanteigado', 9),
(14, 'Muffin de mirtilo', 17);

UPDATE ESTOQUE SET estoque_minimo=5 WHERE id_produto BETWEEN 9 AND 14;
INSERT INTO MOVIMENTACAO_ESTOQUE (id_produto, id_funcionario, tipo, quantidade, data_hora, motivo, referencia) VALUES
(9, 5, 'ENTRADA', 20, '2026-09-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:09:9'),
(10, 5, 'ENTRADA', 20, '2026-09-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:09:10'),
(11, 5, 'ENTRADA', 20, '2026-09-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:09:11'),
(12, 5, 'ENTRADA', 20, '2026-09-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:09:12'),
(13, 5, 'ENTRADA', 20, '2026-09-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:09:13'),
(14, 5, 'ENTRADA', 20, '2026-09-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:09:14'),
(9, 5, 'ENTRADA', 20, '2026-10-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:10:9'),
(10, 5, 'ENTRADA', 20, '2026-10-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:10:10'),
(11, 5, 'ENTRADA', 20, '2026-10-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:10:11'),
(12, 5, 'ENTRADA', 20, '2026-10-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:10:12'),
(13, 5, 'ENTRADA', 20, '2026-10-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:10:13'),
(14, 5, 'ENTRADA', 20, '2026-10-01 07:00:00', 'Recebimento selecionado para a amostra', 'REC:10:14');

INSERT INTO PEDIDO (id_pedido, id_cliente, id_funcionario, totem, nome_comanda, data_hora, origem_pedido, status_preparo) VALUES
(16, NULL, NULL, 'T01', NULL, '2026-09-05 09:00:00', 'TOTEM', 'RECEBIDO'),
(17, 7, 2, NULL, 'Comanda fictícia 17', '2026-09-06 10:00:00', 'BALCÃO', 'RECEBIDO'),
(18, 8, NULL, NULL, 'Comanda fictícia 18', '2026-09-07 11:00:00', 'DELIVERY', 'RECEBIDO'),
(19, 9, NULL, 'T02', 'Comanda fictícia 19', '2026-09-08 12:00:00', 'TOTEM', 'RECEBIDO'),
(20, 10, NULL, NULL, NULL, '2026-09-09 13:00:00', 'BALCÃO', 'RECEBIDO'),
(21, NULL, NULL, NULL, 'Comanda fictícia 21', '2026-09-10 14:00:00', 'DELIVERY', 'RECEBIDO'),
(22, 12, NULL, 'T01', 'Comanda fictícia 22', '2026-09-11 15:00:00', 'TOTEM', 'RECEBIDO'),
(23, 13, 8, NULL, 'Comanda fictícia 23', '2026-09-12 16:00:00', 'BALCÃO', 'RECEBIDO'),
(24, 14, NULL, NULL, NULL, '2026-09-13 17:00:00', 'DELIVERY', 'RECEBIDO'),
(25, 15, NULL, 'T02', 'Comanda fictícia 25', '2026-09-14 18:00:00', 'TOTEM', 'RECEBIDO'),
(26, NULL, 3, NULL, 'Comanda fictícia 26', '2026-09-15 19:00:00', 'BALCÃO', 'RECEBIDO'),
(27, 17, NULL, NULL, 'Comanda fictícia 27', '2026-09-16 09:00:00', 'DELIVERY', 'RECEBIDO'),
(28, 18, NULL, 'T01', NULL, '2026-09-17 10:00:00', 'TOTEM', 'RECEBIDO'),
(29, 6, 6, NULL, 'Comanda fictícia 29', '2026-09-18 11:00:00', 'BALCÃO', 'RECEBIDO'),
(30, 7, NULL, NULL, 'Comanda fictícia 30', '2026-09-19 12:00:00', 'DELIVERY', 'RECEBIDO'),
(31, NULL, NULL, 'T02', 'Comanda fictícia 31', '2026-10-01 13:00:00', 'TOTEM', 'RECEBIDO'),
(32, 9, NULL, NULL, NULL, '2026-10-02 14:00:00', 'BALCÃO', 'RECEBIDO'),
(33, 10, NULL, NULL, 'Comanda fictícia 33', '2026-10-03 15:00:00', 'DELIVERY', 'RECEBIDO'),
(34, 11, NULL, 'T01', 'Comanda fictícia 34', '2026-10-04 16:00:00', 'TOTEM', 'RECEBIDO'),
(35, 12, 4, NULL, 'Comanda fictícia 35', '2026-10-05 17:00:00', 'BALCÃO', 'RECEBIDO'),
(36, NULL, NULL, NULL, NULL, '2026-10-06 18:00:00', 'DELIVERY', 'RECEBIDO'),
(37, 14, NULL, 'T02', 'Comanda fictícia 37', '2026-10-07 19:00:00', 'TOTEM', 'RECEBIDO'),
(38, 15, 7, NULL, 'Comanda fictícia 38', '2026-10-08 09:00:00', 'BALCÃO', 'RECEBIDO'),
(39, 16, NULL, NULL, 'Comanda fictícia 39', '2026-10-09 10:00:00', 'DELIVERY', 'RECEBIDO'),
(40, 17, NULL, 'T01', NULL, '2026-10-10 11:00:00', 'TOTEM', 'RECEBIDO'),
(41, NULL, 2, NULL, 'Comanda fictícia 41', '2026-10-11 12:00:00', 'BALCÃO', 'RECEBIDO'),
(42, 6, NULL, NULL, 'Comanda fictícia 42', '2026-10-12 13:00:00', 'DELIVERY', 'RECEBIDO'),
(43, 7, NULL, 'T02', 'Comanda fictícia 43', '2026-10-13 14:00:00', 'TOTEM', 'RECEBIDO'),
(44, 8, NULL, NULL, NULL, '2026-10-14 15:00:00', 'BALCÃO', 'RECEBIDO'),
(45, 9, NULL, NULL, 'Comanda fictícia 45', '2026-10-15 16:00:00', 'DELIVERY', 'RECEBIDO'),
(46, NULL, NULL, 'T01', 'Comanda fictícia 46', '2026-10-16 17:00:00', 'TOTEM', 'RECEBIDO'),
(47, 11, 8, NULL, 'Comanda fictícia 47', '2026-10-17 18:00:00', 'BALCÃO', 'RECEBIDO'),
(48, 12, NULL, NULL, NULL, '2026-10-18 19:00:00', 'DELIVERY', 'RECEBIDO'),
(49, 13, NULL, 'T02', 'Comanda fictícia 49', '2026-10-19 09:00:00', 'TOTEM', 'RECEBIDO'),
(50, 14, 3, NULL, 'Comanda fictícia 50', '2026-10-20 10:00:00', 'BALCÃO', 'RECEBIDO'),
(51, NULL, NULL, NULL, 'Comanda fictícia 51', '2026-10-21 11:00:00', 'DELIVERY', 'RECEBIDO'),
(52, 16, NULL, 'T01', NULL, '2026-10-22 12:00:00', 'TOTEM', 'RECEBIDO'),
(53, 17, 6, NULL, 'Comanda fictícia 53', '2026-10-23 13:00:00', 'BALCÃO', 'RECEBIDO'),
(54, 18, NULL, NULL, 'Comanda fictícia 54', '2026-10-24 14:00:00', 'DELIVERY', 'RECEBIDO'),
(55, 6, NULL, 'T02', 'Comanda fictícia 55', '2026-10-25 15:00:00', 'TOTEM', 'RECEBIDO'),
(56, NULL, NULL, NULL, NULL, '2026-10-26 16:00:00', 'BALCÃO', 'RECEBIDO'),
(57, 8, NULL, NULL, 'Comanda fictícia 57', '2026-10-27 17:00:00', 'DELIVERY', 'RECEBIDO'),
(58, 9, NULL, 'T01', 'Comanda fictícia 58', '2026-10-28 18:00:00', 'TOTEM', 'RECEBIDO'),
(59, 10, 4, NULL, 'Comanda fictícia 59', '2026-10-29 19:00:00', 'BALCÃO', 'RECEBIDO'),
(60, 11, NULL, NULL, NULL, '2026-10-30 09:00:00', 'DELIVERY', 'RECEBIDO');

INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(16, 9, 1, 22),
(17, 10, 2, 19),
(17, 11, 1, 14),
(18, 11, 1, 14),
(18, 12, 2, 24),
(18, 13, 1, 9),
(19, 12, 2, 24),
(20, 13, 1, 9),
(20, 14, 2, 17),
(21, 14, 2, 17),
(21, 9, 1, 22),
(21, 10, 2, 19),
(22, 9, 1, 22),
(23, 10, 2, 19),
(23, 11, 1, 14),
(24, 11, 1, 14),
(24, 12, 2, 24),
(24, 13, 1, 9),
(25, 12, 2, 24),
(26, 13, 1, 9),
(26, 14, 2, 17),
(27, 14, 2, 17),
(27, 9, 1, 22),
(27, 10, 2, 19),
(28, 9, 1, 22),
(29, 10, 2, 19),
(29, 11, 1, 14),
(30, 11, 1, 14),
(30, 12, 2, 24),
(30, 13, 1, 9),
(31, 12, 2, 24),
(32, 13, 1, 9),
(32, 14, 2, 17),
(33, 14, 2, 17),
(33, 9, 1, 22),
(33, 10, 2, 19),
(34, 9, 1, 22),
(35, 10, 2, 19),
(35, 11, 1, 14),
(36, 11, 1, 14),
(36, 12, 2, 24),
(36, 13, 1, 9),
(37, 12, 2, 24),
(38, 13, 1, 9),
(38, 14, 2, 17),
(39, 14, 2, 17),
(39, 9, 1, 22),
(39, 10, 2, 19),
(40, 9, 1, 22),
(41, 10, 2, 19),
(41, 11, 1, 14),
(42, 11, 1, 14),
(42, 12, 2, 24),
(42, 13, 1, 9),
(43, 12, 2, 24),
(44, 13, 1, 9),
(44, 14, 2, 17),
(45, 14, 2, 17),
(45, 9, 1, 22),
(45, 10, 2, 19),
(46, 9, 1, 22),
(47, 10, 2, 19),
(47, 11, 1, 14),
(48, 11, 1, 14),
(48, 12, 2, 24),
(48, 13, 1, 9),
(49, 12, 2, 24),
(50, 13, 1, 9),
(50, 14, 2, 17),
(51, 14, 2, 17),
(51, 9, 1, 22),
(51, 10, 2, 19),
(52, 9, 1, 22),
(53, 10, 2, 19),
(53, 11, 1, 14),
(54, 11, 1, 14),
(54, 12, 2, 24),
(54, 13, 1, 9),
(55, 12, 2, 24),
(56, 13, 1, 9),
(56, 14, 2, 17),
(57, 14, 2, 17),
(57, 9, 1, 22),
(57, 10, 2, 19),
(58, 9, 1, 22),
(59, 10, 2, 19),
(59, 11, 1, 14),
(60, 11, 1, 14),
(60, 12, 2, 24),
(60, 13, 1, 9);

INSERT INTO CUPOM_FISCAL (id_cupom_fiscal, id_pedido, numero, data_hora_emissao) VALUES
(16, 16, 'SIM-2026-0016', '2026-09-05 09:00:00'),
(17, 17, 'SIM-2026-0017', '2026-09-06 10:00:00'),
(18, 18, 'SIM-2026-0018', '2026-09-07 11:00:00'),
(19, 19, 'SIM-2026-0019', '2026-09-08 12:00:00'),
(20, 20, 'SIM-2026-0020', '2026-09-09 13:00:00'),
(21, 21, 'SIM-2026-0021', '2026-09-10 14:00:00'),
(22, 22, 'SIM-2026-0022', '2026-09-11 15:00:00'),
(23, 23, 'SIM-2026-0023', '2026-09-12 16:00:00'),
(24, 24, 'SIM-2026-0024', '2026-09-13 17:00:00'),
(25, 25, 'SIM-2026-0025', '2026-09-14 18:00:00'),
(26, 26, 'SIM-2026-0026', '2026-09-15 19:00:00'),
(27, 27, 'SIM-2026-0027', '2026-09-16 09:00:00'),
(28, 28, 'SIM-2026-0028', '2026-09-17 10:00:00'),
(29, 29, 'SIM-2026-0029', '2026-09-18 11:00:00'),
(30, 30, 'SIM-2026-0030', '2026-09-19 12:00:00'),
(31, 31, 'SIM-2026-0031', '2026-10-01 13:00:00'),
(32, 32, 'SIM-2026-0032', '2026-10-02 14:00:00'),
(33, 33, 'SIM-2026-0033', '2026-10-03 15:00:00'),
(34, 34, 'SIM-2026-0034', '2026-10-04 16:00:00'),
(35, 35, 'SIM-2026-0035', '2026-10-05 17:00:00'),
(36, 36, 'SIM-2026-0036', '2026-10-06 18:00:00'),
(37, 37, 'SIM-2026-0037', '2026-10-07 19:00:00'),
(38, 38, 'SIM-2026-0038', '2026-10-08 09:00:00'),
(39, 39, 'SIM-2026-0039', '2026-10-09 10:00:00'),
(40, 40, 'SIM-2026-0040', '2026-10-10 11:00:00'),
(41, 41, 'SIM-2026-0041', '2026-10-11 12:00:00'),
(42, 42, 'SIM-2026-0042', '2026-10-12 13:00:00'),
(43, 43, 'SIM-2026-0043', '2026-10-13 14:00:00'),
(44, 44, 'SIM-2026-0044', '2026-10-14 15:00:00'),
(45, 45, 'SIM-2026-0045', '2026-10-15 16:00:00'),
(46, 46, 'SIM-2026-0046', '2026-10-16 17:00:00'),
(47, 47, 'SIM-2026-0047', '2026-10-17 18:00:00'),
(48, 48, 'SIM-2026-0048', '2026-10-18 19:00:00'),
(49, 49, 'SIM-2026-0049', '2026-10-19 09:00:00'),
(50, 50, 'SIM-2026-0050', '2026-10-20 10:00:00'),
(51, 51, 'SIM-2026-0051', '2026-10-21 11:00:00'),
(52, 52, 'SIM-2026-0052', '2026-10-22 12:00:00'),
(53, 53, 'SIM-2026-0053', '2026-10-23 13:00:00'),
(54, 54, 'SIM-2026-0054', '2026-10-24 14:00:00'),
(55, 55, 'SIM-2026-0055', '2026-10-25 15:00:00'),
(56, 56, 'SIM-2026-0056', '2026-10-26 16:00:00'),
(57, 57, 'SIM-2026-0057', '2026-10-27 17:00:00'),
(58, 58, 'SIM-2026-0058', '2026-10-28 18:00:00'),
(59, 59, 'SIM-2026-0059', '2026-10-29 19:00:00'),
(60, 60, 'SIM-2026-0060', '2026-10-30 09:00:00');

INSERT INTO PAGAMENTO (id_pagamento, id_cupom_fiscal, forma_pagamento, valor_pagamento, status_pagamento, data_hora_pagamento) VALUES
(18, 16, 'PIX', 22, 'Recusado', '2026-09-05 09:00:30'),
(19, 17, 'Crédito', 26, 'Aprovado', '2026-09-06 10:00:30'),
(20, 18, 'Débito', 71, 'Aprovado', '2026-09-07 11:00:30'),
(21, 19, 'PIX', 10, 'Aprovado', '2026-09-08 12:00:30'),
(22, 19, 'Débito', 38, 'Aprovado', '2026-09-08 12:00:30'),
(23, 20, 'Crédito', 43, 'Recusado', '2026-09-09 13:00:30'),
(24, 20, 'Dinheiro', 43, 'Aprovado', '2026-09-09 13:00:30'),
(25, 21, 'Crédito', 94, 'Aprovado', '2026-09-10 14:00:30'),
(26, 22, 'Débito', 22, 'Aprovado', '2026-09-11 15:00:30'),
(27, 23, 'Dinheiro', 52, 'Aprovado', '2026-09-12 16:00:30'),
(28, 24, 'PIX', 71, 'Aprovado', '2026-09-13 17:00:30'),
(29, 25, 'Crédito', 48, 'Aprovado', '2026-09-14 18:00:30'),
(30, 26, 'Débito', 43, 'Recusado', '2026-09-15 19:00:30'),
(31, 27, 'Dinheiro', 47, 'Aprovado', '2026-09-16 09:00:30'),
(32, 28, 'PIX', 22, 'Aprovado', '2026-09-17 10:00:30'),
(33, 29, 'PIX', 10, 'Aprovado', '2026-09-18 11:00:30'),
(34, 29, 'Débito', 42, 'Aprovado', '2026-09-18 11:00:30'),
(35, 30, 'Crédito', 71, 'Recusado', '2026-09-19 12:00:30'),
(36, 30, 'Dinheiro', 71, 'Aprovado', '2026-09-19 12:00:30'),
(37, 31, 'Dinheiro', 48, 'Aprovado', '2026-10-01 13:00:30'),
(38, 32, 'PIX', 43, 'Aprovado', '2026-10-02 14:00:30'),
(39, 33, 'Crédito', 94, 'Aprovado', '2026-10-03 15:00:30'),
(40, 34, 'Débito', 22, 'Aprovado', '2026-10-04 16:00:30'),
(41, 35, 'Dinheiro', 52, 'Aprovado', '2026-10-05 17:00:30'),
(42, 36, 'PIX', 71, 'Recusado', '2026-10-06 18:00:30'),
(43, 37, 'Crédito', 24, 'Aprovado', '2026-10-07 19:00:30'),
(44, 38, 'Débito', 43, 'Aprovado', '2026-10-08 09:00:30'),
(45, 39, 'PIX', 10, 'Aprovado', '2026-10-09 10:00:30'),
(46, 39, 'Débito', 84, 'Aprovado', '2026-10-09 10:00:30'),
(47, 40, 'Crédito', 22, 'Recusado', '2026-10-10 11:00:30'),
(48, 40, 'Dinheiro', 22, 'Aprovado', '2026-10-10 11:00:30'),
(49, 41, 'Crédito', 52, 'Aprovado', '2026-10-11 12:00:30'),
(50, 42, 'Débito', 71, 'Aprovado', '2026-10-12 13:00:30'),
(51, 43, 'Dinheiro', 48, 'Aprovado', '2026-10-13 14:00:30'),
(52, 44, 'PIX', 43, 'Aprovado', '2026-10-14 15:00:30'),
(53, 45, 'Crédito', 94, 'Aprovado', '2026-10-15 16:00:30'),
(54, 46, 'Débito', 22, 'Recusado', '2026-10-16 17:00:30'),
(55, 47, 'Dinheiro', 26, 'Aprovado', '2026-10-17 18:00:30'),
(56, 48, 'PIX', 71, 'Aprovado', '2026-10-18 19:00:30'),
(57, 49, 'PIX', 10, 'Aprovado', '2026-10-19 09:00:30'),
(58, 49, 'Débito', 38, 'Aprovado', '2026-10-19 09:00:30'),
(59, 50, 'Crédito', 43, 'Recusado', '2026-10-20 10:00:30'),
(60, 50, 'Dinheiro', 43, 'Aprovado', '2026-10-20 10:00:30'),
(61, 51, 'Dinheiro', 94, 'Aprovado', '2026-10-21 11:00:30'),
(62, 52, 'PIX', 22, 'Aprovado', '2026-10-22 12:00:30'),
(63, 53, 'Crédito', 52, 'Aprovado', '2026-10-23 13:00:30'),
(64, 54, 'Débito', 71, 'Aprovado', '2026-10-24 14:00:30'),
(65, 55, 'Dinheiro', 48, 'Aprovado', '2026-10-25 15:00:30'),
(66, 56, 'PIX', 43, 'Recusado', '2026-10-26 16:00:30'),
(67, 57, 'Crédito', 47, 'Aprovado', '2026-10-27 17:00:30'),
(68, 58, 'Débito', 22, 'Aprovado', '2026-10-28 18:00:30'),
(69, 59, 'PIX', 10, 'Aprovado', '2026-10-29 19:00:30'),
(70, 59, 'Débito', 42, 'Aprovado', '2026-10-29 19:00:30'),
(71, 60, 'Crédito', 71, 'Recusado', '2026-10-30 09:00:30'),
(72, 60, 'Dinheiro', 71, 'Aprovado', '2026-10-30 09:00:30');

COMMIT;

SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-08 12:01:00');
CALL sp_liberar_preparo(19,4);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-09 13:01:00');
CALL sp_liberar_preparo(20,5);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=20;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-10 14:01:00');
CALL sp_liberar_preparo(21,6);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=21;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=21;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-11 15:01:00');
CALL sp_liberar_preparo(22,7);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-12 16:01:00');
CALL sp_liberar_preparo(23,8);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=23;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-13 17:01:00');
CALL sp_liberar_preparo(24,1);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=24;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=24;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-14 18:01:00');
CALL sp_liberar_preparo(25,2);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-18 11:01:00');
CALL sp_liberar_preparo(29,6);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=29;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-09-19 12:01:00');
CALL sp_liberar_preparo(30,7);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=30;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=30;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-01 13:01:00');
CALL sp_liberar_preparo(31,8);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-02 14:01:00');
CALL sp_liberar_preparo(32,1);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=32;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-03 15:01:00');
CALL sp_liberar_preparo(33,2);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=33;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=33;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-04 16:01:00');
CALL sp_liberar_preparo(34,3);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-05 17:01:00');
CALL sp_liberar_preparo(35,4);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=35;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-09 10:01:00');
CALL sp_liberar_preparo(39,8);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=39;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=39;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-10 11:01:00');
CALL sp_liberar_preparo(40,1);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-11 12:01:00');
CALL sp_liberar_preparo(41,2);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=41;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-12 13:01:00');
CALL sp_liberar_preparo(42,3);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=42;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=42;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-13 14:01:00');
CALL sp_liberar_preparo(43,4);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-14 15:01:00');
CALL sp_liberar_preparo(44,5);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=44;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-15 16:01:00');
CALL sp_liberar_preparo(45,6);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=45;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=45;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-19 09:01:00');
CALL sp_liberar_preparo(49,2);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-20 10:01:00');
CALL sp_liberar_preparo(50,3);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=50;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-21 11:01:00');
CALL sp_liberar_preparo(51,4);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=51;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=51;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-22 12:01:00');
CALL sp_liberar_preparo(52,5);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-23 13:01:00');
CALL sp_liberar_preparo(53,6);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=53;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-24 14:01:00');
CALL sp_liberar_preparo(54,7);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=54;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=54;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-25 15:01:00');
CALL sp_liberar_preparo(55,8);
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-29 19:01:00');
CALL sp_liberar_preparo(59,4);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=59;
SET TIMESTAMP=UNIX_TIMESTAMP('2026-10-30 09:01:00');
CALL sp_liberar_preparo(60,5);
UPDATE PEDIDO SET status_preparo='PRONTO' WHERE id_pedido=60;
UPDATE PEDIDO SET status_preparo='ENTREGUE' WHERE id_pedido=60;
UPDATE PEDIDO SET status_preparo='CANCELADO' WHERE id_pedido IN (18,28,38,48,58);
UPDATE PAGAMENTO SET status_pagamento='Estornado' WHERE id_cupom_fiscal IN (18,28,38,48,58);
SET TIMESTAMP=0;

-- 5. SELECT COM JOIN — detalhamento dos pedidos fictícios.
SELECT p.id_pedido, p.origem_pedido, pr.nome AS produto, i.quantidade,
       i.preco_unitario, c.numero AS numero_cupom
FROM PEDIDO p
JOIN ITEM_PEDIDO i ON i.id_pedido = p.id_pedido
JOIN PRODUTO pr ON pr.id_produto = i.id_produto
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
ORDER BY p.id_pedido, i.id_produto;

-- 6. UPDATE — preço atual sem alterar o histórico de venda.
UPDATE PRODUTO SET preco = 11.00 WHERE id_produto = 1;
SELECT pr.id_produto, pr.preco AS preco_atual, i.id_pedido, i.preco_unitario AS preco_historico
FROM PRODUTO pr JOIN ITEM_PEDIDO i ON i.id_produto = pr.id_produto
WHERE pr.id_produto = 1;

-- 7. DELETE — remover somente cadastro fictício sem nenhuma venda associada.
DELETE FROM ESTOQUE WHERE id_produto=8 AND quantidade_disponivel=0
  AND NOT EXISTS (SELECT 1 FROM MOVIMENTACAO_ESTOQUE m WHERE m.id_produto=ESTOQUE.id_produto);
DELETE FROM PRODUTO WHERE id_produto = 8
  AND NOT EXISTS (SELECT 1 FROM ITEM_PEDIDO i WHERE i.id_produto = PRODUTO.id_produto);
SELECT COUNT(*) AS produto_temporario_remanescente FROM PRODUTO WHERE id_produto = 8;

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
), classificados AS (
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
WHERE p.data_hora >= @inicio AND p.data_hora < @fim
)
SELECT classificados.*, COUNT(*) OVER (PARTITION BY situacao) AS quantidade_na_situacao
FROM classificados
ORDER BY situacao, id_pedido;

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
 CASE WHEN e.quantidade_disponivel<=e.estoque_minimo THEN 'REPOR' ELSE 'REGULAR' END AS reposicao,
 SUM(CASE WHEN e.quantidade_disponivel=0 THEN 1 ELSE 0 END) OVER () AS produtos_indisponiveis,
 SUM(CASE WHEN e.quantidade_disponivel<=e.estoque_minimo THEN 1 ELSE 0 END) OVER () AS produtos_para_repor
FROM PRODUTO pr JOIN ESTOQUE e ON e.id_produto=pr.id_produto
ORDER BY e.quantidade_disponivel,pr.id_produto;

-- G09 — Qual a quantidade movimentada por produto e tipo no período?
-- Atende: P2; K12 (entradas, consumo, perdas e ajustes por produto).
-- Fluxo pelo horário da movimentação; não calcula custo ou valor de desperdício.
SELECT pr.id_produto,pr.nome,m.tipo,SUM(m.quantidade) AS unidades
FROM MOVIMENTACAO_ESTOQUE m JOIN PRODUTO pr ON pr.id_produto=m.id_produto
WHERE m.data_hora>=@inicio AND m.data_hora<@fim
GROUP BY pr.id_produto,pr.nome,m.tipo ORDER BY pr.id_produto,m.tipo;

-- G10 — Qual e o valor diario de vendas quitadas e o ticket medio por canal?
-- Atende: P1; K01; K02; RF16 (consolidacao diaria).
-- Convencao: dia civil pela data do pedido; nao efetiva fechamento nem preserva snapshot.
WITH itens AS (
 SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
 FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
 SELECT id_cupom_fiscal,
        SUM(CASE WHEN status_pagamento='Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
 FROM PAGAMENTO GROUP BY id_cupom_fiscal
)
SELECT DATE(p.data_hora) AS dia, p.origem_pedido,
       COUNT(*) AS pedidos_quitados, SUM(i.total) AS valor_vendas_quitadas,
       AVG(i.total) AS ticket_medio
FROM PEDIDO p
JOIN itens i ON i.id_pedido=p.id_pedido
JOIN CUPOM_FISCAL c ON c.id_pedido=p.id_pedido
JOIN pagos pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal
WHERE p.data_hora>=@inicio AND p.data_hora<@fim
  AND p.status_preparo<>'CANCELADO' AND pg.pago=i.total
GROUP BY DATE(p.data_hora), p.origem_pedido
ORDER BY dia, p.origem_pedido;

-- 9. CONSULTAS DE AUDITORIA — retornam exceções a conferir, não apagam dados.

-- A01 — Existe pedido sem nenhum item?
-- Verifica: RN11 (todo pedido deve conter ao menos um produto).
SELECT p.id_pedido FROM PEDIDO p
LEFT JOIN ITEM_PEDIDO i ON i.id_pedido = p.id_pedido
WHERE i.id_pedido IS NULL;

-- A02 — Existe pedido sem exatamente um cupom fiscal?
-- Verifica: RN14 (cada pedido gera exatamente um cupom).
SELECT p.id_pedido, COUNT(c.id_cupom_fiscal) AS cupons
FROM PEDIDO p LEFT JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
GROUP BY p.id_pedido HAVING COUNT(c.id_cupom_fiscal) <> 1;

-- A03 — Existe cupom sem tentativa de pagamento?
-- Verifica: RN16 (cada cupom possui um ou mais registros de pagamento).
SELECT c.id_cupom_fiscal FROM CUPOM_FISCAL c
LEFT JOIN PAGAMENTO pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE pg.id_pagamento IS NULL;

-- A04 — Existe pedido em preparo, pronto ou entregue sem quitação exata?
-- Verifica: RN13, RN19, RN20, RN22 (total derivado, apenas aprovados e liberação quitada).
WITH itens AS (
 SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
 FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
 SELECT id_cupom_fiscal,
        SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
 FROM PAGAMENTO GROUP BY id_cupom_fiscal
)
SELECT p.id_pedido, i.total, COALESCE(pg.pago,0) AS valor_pago
FROM PEDIDO p
LEFT JOIN itens i ON i.id_pedido = p.id_pedido
LEFT JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
LEFT JOIN pagos pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE p.status_preparo IN ('EM_PREPARO','PRONTO','ENTREGUE')
 AND (i.total IS NULL OR COALESCE(pg.pago,0) <> i.total);

-- A05 — Há cancelamento com devolução financeira pendente?
-- Exceção fictícia de teste: não representa o fluxo normal imediato da entrevista.
-- A consulta não comprova devolução na operadora nem autoriza cancelamento fiscal.
-- Verifica: RN23, RN24: aprovados permanecem assim até confirmar devolução.
SELECT p.id_pedido, SUM(pg.valor_pagamento) AS devolver
FROM PEDIDO p
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
JOIN PAGAMENTO pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE p.status_preparo = 'CANCELADO' AND pg.status_pagamento = 'Aprovado'
GROUP BY p.id_pedido;

-- A06 — Há origem ou identificação de totem incompatível com o canal?
-- Verifica: RN07: totem obrigatório somente no autoatendimento.
SELECT id_pedido, origem_pedido, totem FROM PEDIDO
WHERE origem_pedido NOT IN ('TOTEM','BALCÃO','DELIVERY')
 OR (origem_pedido = 'TOTEM' AND (totem IS NULL OR CHAR_LENGTH(TRIM(totem)) = 0))
 OR (origem_pedido <> 'TOTEM' AND totem IS NOT NULL);

-- A07 — Existem referências órfãs nas relações do modelo?
-- Verifica: RN03, RN06, RN11, RN14, RN16: existência dos registros referenciados.
SELECT 'PEDIDO_CLIENTE' AS vinculo, p.id_pedido AS registro FROM PEDIDO p
LEFT JOIN CLIENTE c ON c.id_cliente = p.id_cliente
WHERE p.id_cliente IS NOT NULL AND c.id_cliente IS NULL
UNION ALL
SELECT 'PEDIDO_FUNCIONARIO', p.id_pedido FROM PEDIDO p
LEFT JOIN FUNCIONARIO f ON f.id_funcionario = p.id_funcionario
WHERE p.id_funcionario IS NOT NULL AND f.id_funcionario IS NULL
UNION ALL
SELECT 'ITEM_PEDIDO', i.id_pedido FROM ITEM_PEDIDO i
LEFT JOIN PEDIDO p ON p.id_pedido = i.id_pedido WHERE p.id_pedido IS NULL
UNION ALL
SELECT 'ITEM_PRODUTO', i.id_pedido FROM ITEM_PEDIDO i
LEFT JOIN PRODUTO pr ON pr.id_produto = i.id_produto WHERE pr.id_produto IS NULL
UNION ALL
SELECT 'CUPOM_PEDIDO', c.id_cupom_fiscal FROM CUPOM_FISCAL c
LEFT JOIN PEDIDO p ON p.id_pedido = c.id_pedido WHERE p.id_pedido IS NULL
UNION ALL
SELECT 'PAGAMENTO_CUPOM', pg.id_pagamento FROM PAGAMENTO pg
LEFT JOIN CUPOM_FISCAL c ON c.id_cupom_fiscal = pg.id_cupom_fiscal
WHERE c.id_cupom_fiscal IS NULL;

-- A08 — Há itens com quantidade inválida ou pagamentos com valor inválido?
-- Verifica: RN11, RN17: valores obrigatórios e positivos.
SELECT 'ITEM' AS tipo, id_pedido AS registro FROM ITEM_PEDIDO
WHERE quantidade IS NULL OR quantidade <= 0
UNION ALL
SELECT 'PAGAMENTO', id_pagamento FROM PAGAMENTO
WHERE valor_pagamento IS NULL OR valor_pagamento <= 0;

-- A09 — Há documento de cliente ou número fiscal duplicado?
-- Verifica: RN02, RN15: unicidade quando aplicável.
SELECT 'CPF_CNPJ' AS tipo, cpf_cnpj AS valor, COUNT(*) AS ocorrencias
FROM CLIENTE WHERE cpf_cnpj IS NOT NULL GROUP BY cpf_cnpj HAVING COUNT(*) > 1
UNION ALL
SELECT 'NUMERO_FISCAL', numero, COUNT(*) FROM CUPOM_FISCAL
GROUP BY numero HAVING COUNT(*) > 1;

-- A10 — A alteração do preço atual preservou o histórico do produto 1?
-- Verifica: RN12: cenário controlado com preço histórico original de 10.00.
SELECT id_pedido, id_produto, preco_unitario FROM ITEM_PEDIDO
WHERE id_produto = 1 AND preco_unitario <> 10.00;

-- A11 — Há recebimentos aprovados acima do total do pedido?
-- Verifica: RN13, RN19, RN20: excesso é divergência, não quitação regular.
WITH itens AS (
 SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
 FROM ITEM_PEDIDO GROUP BY id_pedido
), pagos AS (
 SELECT id_cupom_fiscal,
        SUM(CASE WHEN status_pagamento = 'Aprovado' THEN valor_pagamento ELSE 0 END) AS pago
 FROM PAGAMENTO GROUP BY id_cupom_fiscal
)
SELECT p.id_pedido, i.total, pg.pago, pg.pago - i.total AS excesso
FROM PEDIDO p
JOIN itens i ON i.id_pedido = p.id_pedido
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
JOIN pagos pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE pg.pago > i.total;

-- A12 — O saldo materializado corresponde ao histórico?
-- Verifica: RN25, RN26, RN29, RN32: saldo conciliado e histórico preservado.
SELECT e.id_produto,e.quantidade_disponivel,
 COALESCE(SUM(CASE WHEN m.tipo IN ('ENTRADA','AJUSTE_ENTRADA','RETORNO')
                  THEN m.quantidade ELSE -m.quantidade END),0) AS saldo_movimentos
FROM ESTOQUE e LEFT JOIN MOVIMENTACAO_ESTOQUE m ON m.id_produto=e.id_produto
GROUP BY e.id_produto,e.quantidade_disponivel
HAVING e.quantidade_disponivel<0 OR e.quantidade_disponivel<>saldo_movimentos;

-- A13 — Há item liberado sem baixa integral e única?
-- Verifica: RN27: baixa integral uma vez por item.
SELECT i.id_pedido,i.id_produto,i.quantidade,COUNT(m.id_movimentacao) AS baixas,
 COALESCE(SUM(m.quantidade),0) AS quantidade_baixada
FROM PEDIDO p JOIN ITEM_PEDIDO i ON i.id_pedido=p.id_pedido
LEFT JOIN MOVIMENTACAO_ESTOQUE m ON m.id_pedido=i.id_pedido
 AND m.id_produto=i.id_produto AND m.tipo='VENDA'
WHERE p.status_preparo IN ('EM_PREPARO','PRONTO','ENTREGUE')
GROUP BY i.id_pedido,i.id_produto,i.quantidade
HAVING baixas<>1 OR quantidade_baixada<>i.quantidade;

-- A14 — Há retorno sem cancelamento ou sem baixa compatível?
-- Verifica: RN28: retorno após baixa e cancelamento sem duplicação.
SELECT r.id_movimentacao,r.id_pedido,r.id_produto
FROM MOVIMENTACAO_ESTOQUE r JOIN PEDIDO p ON p.id_pedido=r.id_pedido
LEFT JOIN MOVIMENTACAO_ESTOQUE v ON v.id_pedido=r.id_pedido
 AND v.id_produto=r.id_produto AND v.tipo='VENDA'
WHERE r.tipo='RETORNO' AND (p.status_preparo<>'CANCELADO'
 OR v.id_movimentacao IS NULL OR r.quantidade<>v.quantidade);

-- A15 — Há produto sem estoque ou configuração negativa?
-- Verifica: RN25, RN30: estoque por produto e valores não negativos.
SELECT pr.id_produto FROM PRODUTO pr LEFT JOIN ESTOQUE e ON e.id_produto=pr.id_produto
WHERE e.id_produto IS NULL OR e.estoque_minimo<0 OR e.quantidade_disponivel<0;

-- A16 — Há baixa em pedido recebido ou movimento sem rastreabilidade?
-- Verifica: RN26, RN27, RN29: baixa vinculada à liberação e responsável/motivo.
SELECT m.id_movimentacao FROM MOVIMENTACAO_ESTOQUE m
LEFT JOIN PEDIDO p ON p.id_pedido=m.id_pedido
WHERE (m.tipo='VENDA' AND p.status_preparo='RECEBIDO')
 OR m.id_funcionario IS NULL OR CHAR_LENGTH(TRIM(m.motivo))=0;
