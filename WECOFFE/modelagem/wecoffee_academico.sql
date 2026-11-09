-- Levantamento: entrevista com o auxiliar geral em 08/11/2026, relatada em 09/11/2026.
-- RN33: fechamento ao final de cada dia, exclusivamente por gerentes (confirmado).
-- RN23/RN24: cancelamento da nota/pedido e estorno imediato pelo cartão,
-- com balanceamento automático no sistema existente (confirmados pelo relato).
-- Este SQL não executa integrações fiscais/de cartão nem registra fechamentos.
-- WE COFFEE — Script completo, massa fictícia, MySQL 8.0.16+
-- Executar uma vez em servidor sem o banco wecoffee_academico.
-- Sem DROP DATABASE: não remove banco existente; interrompa ao primeiro erro.
-- RN23/RN24: procedimento confirmado; integrações externas ainda não implementadas.

-- 1. BANCO
CREATE DATABASE wecoffee_academico CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs;
USE wecoffee_academico;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- 2/3. TABELAS E CONSTRAINTS
-- Proposta física correspondente ao diagrama lógico — MySQL 8.0.16+.
-- Executar em esquema vazio selecionado pelo responsável. Não apaga dados.
-- RN23/RN24: CANCELADO e Estornado representam o procedimento confirmado; ver README 2.7.
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
 CHECK (quantidade > 0)
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

-- Regras entre linhas/tabelas não cabem em CHECK do MySQL:
-- RN11/RN14/RN16: validar item, cupom e tentativa ao concluir o registro.
-- RN12: preservar preço histórico; RN13/RN19/RN20: calcular totais em consulta.
-- RN22/RN27/RN31: liberação implementada na extensão abaixo por rotina e triggers.
-- RN23/RN24: validar transições e confirmação externa da devolução.
-- Cardinalidades mínimas de conclusão e confirmação externa de estorno continuam
-- dependentes da aplicação; a extensão abaixo implementa as operações de estoque.

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

-- 5. SELECT COM JOIN — detalhamento de pedido, produtos e documento fiscal.
SELECT p.id_pedido, p.origem_pedido, pr.nome AS produto, i.quantidade,
       i.preco_unitario, c.numero AS numero_cupom
FROM PEDIDO p
JOIN ITEM_PEDIDO i ON i.id_pedido = p.id_pedido
JOIN PRODUTO pr ON pr.id_produto = i.id_produto
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
ORDER BY p.id_pedido, i.id_produto;

-- 6. UPDATE — preço atual muda; itens de vendas anteriores permanecem intactos (RN12).
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

-- 8. CONSULTAS GERENCIAIS — mesmas consultas G01–G07 da demonstração.
-- Seção 3 — Consultas gerenciais propostas para MySQL 8.
-- Pré-requisito: executar docs/script.sql para criar e carregar as tabelas.
-- Este arquivo não cria tabelas nem altera dados.
-- BALCÃO, Crédito e Débito preservam os domínios do levantamento.
-- Cancelamento/estorno confirmados na entrevista; outras formas e permissões a detalhar.
-- A data de corte é exclusiva; ajuste o período para a análise.
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
-- Verifica: RN23, RN24 (exceção: aprovado sem confirmação da devolução).
-- Resultado é pendência operacional, não prova de violação da regra.
SELECT p.id_pedido, SUM(pg.valor_pagamento) AS devolver
FROM PEDIDO p
JOIN CUPOM_FISCAL c ON c.id_pedido = p.id_pedido
JOIN PAGAMENTO pg ON pg.id_cupom_fiscal = c.id_cupom_fiscal
WHERE p.status_preparo = 'CANCELADO' AND pg.status_pagamento = 'Aprovado'
GROUP BY p.id_pedido;

-- A06 — Há origem ou identificação de totem incompatível com o canal?
-- Verifica: RN07 (totem obrigatório somente no autoatendimento).
SELECT id_pedido, origem_pedido, totem FROM PEDIDO
WHERE origem_pedido NOT IN ('TOTEM','BALCÃO','DELIVERY')
 OR (origem_pedido = 'TOTEM' AND (totem IS NULL OR CHAR_LENGTH(TRIM(totem)) = 0))
 OR (origem_pedido <> 'TOTEM' AND totem IS NOT NULL);

-- A07 — Existem referências órfãs nas relações do modelo?
-- Verifica: RN03, RN06, RN11, RN14, RN16 (existência dos registros referenciados).
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
-- Verifica: RN11, RN17 (valores obrigatórios e positivos).
SELECT 'ITEM' AS tipo, id_pedido AS registro FROM ITEM_PEDIDO
WHERE quantidade IS NULL OR quantidade <= 0
UNION ALL
SELECT 'PAGAMENTO', id_pagamento FROM PAGAMENTO
WHERE valor_pagamento IS NULL OR valor_pagamento <= 0;

-- A09 — Há documento de cliente ou número fiscal duplicado?
-- Verifica: RN02, RN15 (unicidade quando aplicável).
SELECT 'CPF_CNPJ' AS tipo, cpf_cnpj AS valor, COUNT(*) AS ocorrencias
FROM CLIENTE WHERE cpf_cnpj IS NOT NULL GROUP BY cpf_cnpj HAVING COUNT(*) > 1
UNION ALL
SELECT 'NUMERO_FISCAL', numero, COUNT(*) FROM CUPOM_FISCAL
GROUP BY numero HAVING COUNT(*) > 1;

-- A10 — A alteração demonstrativa do preço atual preservou as vendas do produto 1?
-- Verifica: RN12 no cenário controlado da massa (preço histórico original = 10.00).
-- Não generalizar este teste para preços históricos desconhecidos em produção.
SELECT id_pedido, id_produto, preco_unitario FROM ITEM_PEDIDO
WHERE id_produto = 1 AND preco_unitario <> 10.00;

-- A11 — Há recebimentos aprovados acima do total do pedido?
-- Verifica: RN13, RN19, RN20 (excesso é divergência, não quitação regular).
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

-- A12 — O saldo materializado corresponde ao histórico de movimentações?
-- Verifica: RN25, RN26, RN29 (saldo conciliado, não negativo e histórico preservado).
SELECT e.id_produto,e.quantidade_disponivel,
 COALESCE(SUM(CASE WHEN m.tipo IN ('ENTRADA','AJUSTE_ENTRADA','RETORNO')
                  THEN m.quantidade ELSE -m.quantidade END),0) AS saldo_movimentos
FROM ESTOQUE e LEFT JOIN MOVIMENTACAO_ESTOQUE m ON m.id_produto=e.id_produto
GROUP BY e.id_produto,e.quantidade_disponivel
HAVING e.quantidade_disponivel<0 OR e.quantidade_disponivel<>saldo_movimentos;

-- A13 — Há item em preparo, pronto ou entregue sem baixa integral e única?
-- Verifica: RN27 (baixa integral uma vez por item na liberação).
SELECT i.id_pedido,i.id_produto,i.quantidade,COUNT(m.id_movimentacao) AS baixas,
 COALESCE(SUM(m.quantidade),0) AS quantidade_baixada
FROM PEDIDO p JOIN ITEM_PEDIDO i ON i.id_pedido=p.id_pedido
LEFT JOIN MOVIMENTACAO_ESTOQUE m ON m.id_pedido=i.id_pedido
 AND m.id_produto=i.id_produto AND m.tipo='VENDA'
WHERE p.status_preparo IN ('EM_PREPARO','PRONTO','ENTREGUE')
GROUP BY i.id_pedido,i.id_produto,i.quantidade
HAVING baixas<>1 OR quantidade_baixada<>i.quantidade;

-- A14 — Há retorno sem cancelamento, sem baixa anterior ou acima da baixa?
-- Verifica: RN28 (retorno após baixa e cancelamento, sem duplicação).
SELECT r.id_movimentacao,r.id_pedido,r.id_produto
FROM MOVIMENTACAO_ESTOQUE r JOIN PEDIDO p ON p.id_pedido=r.id_pedido
LEFT JOIN MOVIMENTACAO_ESTOQUE v ON v.id_pedido=r.id_pedido
 AND v.id_produto=r.id_produto AND v.tipo='VENDA'
WHERE r.tipo='RETORNO' AND (p.status_preparo<>'CANCELADO'
 OR v.id_movimentacao IS NULL OR r.quantidade<>v.quantidade);

-- A15 — Há produto sem registro de estoque ou configuração negativa?
-- Verifica: RN25, RN30 (estoque por produto, mínimo e saldo não negativos).
SELECT pr.id_produto FROM PRODUTO pr LEFT JOIN ESTOQUE e ON e.id_produto=pr.id_produto
WHERE e.id_produto IS NULL OR e.estoque_minimo<0 OR e.quantidade_disponivel<0;

-- A16 — Há baixa em pedido ainda recebido ou movimento sem responsável/motivo?
-- Verifica: RN26, RN27, RN29 (rastreabilidade e baixa vinculada à liberação).
SELECT m.id_movimentacao FROM MOVIMENTACAO_ESTOQUE m
LEFT JOIN PEDIDO p ON p.id_pedido=m.id_pedido
WHERE (m.tipo='VENDA' AND p.status_preparo='RECEBIDO')
 OR m.id_funcionario IS NULL OR CHAR_LENGTH(TRIM(m.motivo))=0;
