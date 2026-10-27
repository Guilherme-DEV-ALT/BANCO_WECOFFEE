-- WE COFFEE | Entrega 2 | 27/10/2026
-- SGBD: MySQL 8.0.16+; teste real em MySQL 8.4 LTS.
-- Executar em banco vazio, pelo cliente mysql (suporta DELIMITER).
-- O schema dedicado wecoffee_entrega2_demo nao e apagado automaticamente.
-- Se ja existir, CREATE DATABASE falha: escolha outro schema de demonstracao
-- antes de executar novamente. Todos os dados de carga sao ficticios.
-- Escopo: vendas, recebimentos e estoque como proposta tecnica a validar.

CREATE DATABASE wecoffee_entrega2_demo
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE wecoffee_entrega2_demo;
SET NAMES utf8mb4;
SET SESSION time_zone='-03:00';
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY';

-- 1. Tabelas e restricoes. RN01: identificadores; RN02-RN13: dominios e vinculos.
CREATE TABLE cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  cpf_cnpj VARCHAR(18) NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cliente_documento UNIQUE (cpf_cnpj),
  CONSTRAINT ck_cliente_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_cliente_documento CHECK (cpf_cnpj IS NULL OR CHAR_LENGTH(TRIM(cpf_cnpj)) BETWEEN 11 AND 18)
) ENGINE=InnoDB;

CREATE TABLE funcionario (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  cargo VARCHAR(60) NOT NULL,
  CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
  CONSTRAINT ck_funcionario_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_funcionario_cargo CHECK (CHAR_LENGTH(TRIM(cargo)) > 0)
) ENGINE=InnoDB;

CREATE TABLE produto (
  id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  quantidade_disponivel INT UNSIGNED NOT NULL DEFAULT 0,
  estoque_minimo INT UNSIGNED NOT NULL DEFAULT 0,
  data_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_produto PRIMARY KEY (id_produto),
  CONSTRAINT ck_produto_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_produto_preco CHECK (preco > 0),
  INDEX ix_produto_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE fornecedor (
  id_fornecedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cnpj VARCHAR(18) NOT NULL,
  CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
  CONSTRAINT ck_fornecedor_cnpj CHECK (CHAR_LENGTH(TRIM(cnpj)) BETWEEN 14 AND 18)
) ENGINE=InnoDB;

CREATE TABLE pedido (
  id_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_cliente INT UNSIGNED NULL,
  id_funcionario INT UNSIGNED NULL,
  totem VARCHAR(50) NULL,
  nome_comanda VARCHAR(120) NULL,
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  origem_pedido CHAR(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  status_preparo VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'RECEBIDO',
  baixa_estoque_realizada BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_pedido_baixa CHECK (baixa_estoque_realizada IN (0,1)),
  CONSTRAINT ck_pedido_origem CHECK (origem_pedido IN ('T','B','D')),
  CONSTRAINT ck_pedido_totem CHECK (
    (origem_pedido='T' AND totem IS NOT NULL AND CHAR_LENGTH(TRIM(totem))>0)
    OR (origem_pedido IN ('B','D') AND totem IS NULL)),
  CONSTRAINT ck_pedido_funcionario CHECK (origem_pedido <> 'B' OR id_funcionario IS NOT NULL),
  CONSTRAINT ck_pedido_comanda CHECK (nome_comanda IS NULL OR CHAR_LENGTH(TRIM(nome_comanda))>0),
  CONSTRAINT ck_pedido_status CHECK (status_preparo IN ('RECEBIDO','EM_PREPARO','PRONTO','ENTREGUE','CANCELADO')),
  INDEX ix_pedido_data (data_hora),
  INDEX ix_pedido_status (status_preparo)
) ENGINE=InnoDB;

-- CONTEM permanece relacionamento N:M no conceitual. Esta e sua tabela logica.
CREATE TABLE pedido_produto (
  id_pedido INT UNSIGNED NOT NULL,
  id_produto INT UNSIGNED NOT NULL,
  quantidade INT UNSIGNED NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  quantidade_devolvida INT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT pk_pedido_produto PRIMARY KEY (id_pedido,id_produto),
  CONSTRAINT fk_pp_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_pp_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_pp_quantidade CHECK (quantidade > 0),
  CONSTRAINT ck_pp_preco CHECK (preco_unitario > 0),
  CONSTRAINT ck_pp_devolvida CHECK (quantidade_devolvida <= quantidade)
) ENGINE=InnoDB;

CREATE TABLE cupom_fiscal (
  id_cupom_fiscal INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pedido INT UNSIGNED NOT NULL,
  numero VARCHAR(50) NOT NULL,
  data_hora_emissao DATETIME NOT NULL,
  CONSTRAINT pk_cupom PRIMARY KEY (id_cupom_fiscal),
  CONSTRAINT uq_cupom_pedido UNIQUE (id_pedido),
  CONSTRAINT uq_cupom_numero UNIQUE (numero),
  CONSTRAINT fk_cupom_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cupom_numero CHECK (CHAR_LENGTH(TRIM(numero))>0)
) ENGINE=InnoDB;

CREATE TABLE pagamento (
  id_pagamento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_cupom_fiscal INT UNSIGNED NOT NULL,
  forma_pagamento CHAR(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  valor_pagamento DECIMAL(10,2) NOT NULL,
  status_pagamento CHAR(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  data_hora_pagamento DATETIME NOT NULL,
  CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
  CONSTRAINT fk_pagamento_cupom FOREIGN KEY (id_cupom_fiscal) REFERENCES cupom_fiscal(id_cupom_fiscal) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_pagamento_forma CHECK (forma_pagamento IN ('P','C','D','X')),
  CONSTRAINT ck_pagamento_status CHECK (status_pagamento IN ('A','R','E')),
  CONSTRAINT ck_pagamento_valor CHECK (valor_pagamento > 0),
  INDEX ix_pagamento_data (data_hora_pagamento)
) ENGINE=InnoDB;

CREATE TABLE entrada_estoque (
  id_entrada_estoque INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_fornecedor INT UNSIGNED NOT NULL,
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_entrada PRIMARY KEY (id_entrada_estoque),
  CONSTRAINT fk_entrada_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor) ON DELETE RESTRICT ON UPDATE RESTRICT,
  INDEX ix_entrada_data (data_hora)
) ENGINE=InnoDB;
CREATE TABLE entrada_produto (
  id_entrada_estoque INT UNSIGNED NOT NULL,
  id_produto INT UNSIGNED NOT NULL,
  quantidade_recebida INT UNSIGNED NOT NULL,
  CONSTRAINT pk_entrada_produto PRIMARY KEY (id_entrada_estoque,id_produto),
  CONSTRAINT fk_ep_entrada FOREIGN KEY (id_entrada_estoque) REFERENCES entrada_estoque(id_entrada_estoque) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_ep_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_ep_quantidade CHECK (quantidade_recebida > 0)
) ENGINE=InnoDB;

-- 2. Informacoes derivadas. Agregar itens e pagamentos separadamente evita
-- multiplicar totais quando ha varios produtos e varios pagamentos no pedido.
CREATE VIEW vw_total_pedido AS
SELECT p.id_pedido,
       CAST(COALESCE(SUM(pp.quantidade * pp.preco_unitario),0) AS DECIMAL(18,2)) AS valor_total,
       COUNT(pp.id_produto) AS produtos_distintos
FROM pedido p LEFT JOIN pedido_produto pp ON pp.id_pedido=p.id_pedido
GROUP BY p.id_pedido;

CREATE VIEW vw_pagamentos_pedido AS
SELECT c.id_pedido,COUNT(pg.id_pagamento) AS tentativas,
       CAST(COALESCE(SUM(CASE WHEN pg.status_pagamento='A' THEN pg.valor_pagamento ELSE 0 END),0) AS DECIMAL(18,2)) AS valor_pago,
       SUM(CASE WHEN pg.status_pagamento='R' THEN 1 ELSE 0 END) AS tentativas_recusadas
FROM cupom_fiscal c LEFT JOIN pagamento pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal
GROUP BY c.id_pedido;

CREATE VIEW vw_situacao_pedido AS
SELECT p.id_pedido,p.id_cliente,p.id_funcionario,p.origem_pedido,p.data_hora,p.status_preparo,
       COALESCE(p.nome_comanda,CAST(p.id_pedido AS CHAR)) AS identificacao_comanda,
       t.valor_total,COALESCE(f.valor_pago,0) AS valor_pago,
       GREATEST(t.valor_total-COALESCE(f.valor_pago,0),0) AS saldo_restante,
       CASE WHEN p.status_preparo='CANCELADO' THEN COALESCE(f.valor_pago,0) ELSE 0 END AS devolucao_pendente,
       COALESCE(f.tentativas,0) AS tentativas,
       CASE
         WHEN p.status_preparo='CANCELADO' AND COALESCE(f.valor_pago,0)>0 THEN 'CANCELADO_DEVOLUCAO_PENDENTE'
         WHEN p.status_preparo='CANCELADO' THEN 'CANCELADO_SEM_DEVOLUCAO'
         WHEN COALESCE(f.valor_pago,0)>t.valor_total THEN 'DIVERGENCIA'
         WHEN t.valor_total>0 AND COALESCE(f.valor_pago,0)=t.valor_total THEN 'QUITADO'
         WHEN COALESCE(f.valor_pago,0)>0 THEN 'PARCIAL'
         ELSE 'SEM_PAGAMENTO'
       END AS situacao_financeira
FROM pedido p JOIN vw_total_pedido t ON t.id_pedido=p.id_pedido
LEFT JOIN vw_pagamentos_pedido f ON f.id_pedido=p.id_pedido;

DELIMITER $$
-- RN06/RN20: preservar quantidade e preco historico apos a primeira tentativa.
CREATE PROCEDURE sp_validar_alteracao_itens(IN p_id INT UNSIGNED)
BEGIN
  DECLARE v_status VARCHAR(20);
  DECLARE v_tentativas INT;
  SELECT status_preparo INTO v_status FROM pedido WHERE id_pedido=p_id FOR UPDATE;
  SELECT COUNT(*) INTO v_tentativas FROM cupom_fiscal c JOIN pagamento pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal WHERE c.id_pedido=p_id;
  IF v_status<>'RECEBIDO' OR v_tentativas>0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN06: itens ficam imutaveis apos tentativa de pagamento';
  END IF;
END$$
CREATE TRIGGER trg_pp_bi BEFORE INSERT ON pedido_produto FOR EACH ROW
BEGIN
  IF NEW.quantidade_devolvida<>0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN27: item inicia sem devolucao'; END IF;
  CALL sp_validar_alteracao_itens(NEW.id_pedido);
END$$
CREATE TRIGGER trg_pp_bu BEFORE UPDATE ON pedido_produto FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(20); DECLARE v_baixa BOOLEAN;
  IF NEW.id_pedido<>OLD.id_pedido OR NEW.id_produto<>OLD.id_produto THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN20: nao reatribuir itens de uma venda';
  END IF;
  IF NEW.quantidade<>OLD.quantidade OR NEW.preco_unitario<>OLD.preco_unitario THEN
    CALL sp_validar_alteracao_itens(OLD.id_pedido);
  END IF;
  IF NEW.quantidade_devolvida<>OLD.quantidade_devolvida THEN
    SELECT status_preparo,baixa_estoque_realizada INTO v_status,v_baixa FROM pedido WHERE id_pedido=OLD.id_pedido FOR UPDATE;
    IF v_status<>'CANCELADO' OR NOT v_baixa OR NEW.quantidade_devolvida<OLD.quantidade_devolvida OR NEW.quantidade_devolvida>NEW.quantidade THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN27: devolucao fisica confirmada deve respeitar quantidade e cancelamento';
    END IF;
    UPDATE produto SET quantidade_disponivel=quantidade_disponivel+(NEW.quantidade_devolvida-OLD.quantidade_devolvida),data_atualizacao=CURRENT_TIMESTAMP
    WHERE id_produto=OLD.id_produto;
  END IF;
END$$
CREATE TRIGGER trg_pp_bd BEFORE DELETE ON pedido_produto FOR EACH ROW
BEGIN CALL sp_validar_alteracao_itens(OLD.id_pedido); END$$

CREATE TRIGGER trg_pedido_bi BEFORE INSERT ON pedido FOR EACH ROW
BEGIN
  IF NEW.status_preparo<>'RECEBIDO' OR NEW.baixa_estoque_realizada<>0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN17: pedido deve iniciar como RECEBIDO';
  END IF;
END$$
CREATE TRIGGER trg_pedido_bu BEFORE UPDATE ON pedido FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(18,2); DECLARE v_pago DECIMAL(18,2);
  IF NEW.id_pedido<>OLD.id_pedido OR NEW.data_hora<>OLD.data_hora OR NEW.origem_pedido<>OLD.origem_pedido
     OR NOT(NEW.totem<=>OLD.totem) OR NOT(NEW.id_cliente<=>OLD.id_cliente) OR NOT(NEW.id_funcionario<=>OLD.id_funcionario) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN20: identidade e origem do pedido sao preservadas';
  END IF;
  IF NEW.baixa_estoque_realizada<>OLD.baixa_estoque_realizada THEN
    SELECT COALESCE(SUM(quantidade*preco_unitario),0) INTO v_total FROM pedido_produto WHERE id_pedido=OLD.id_pedido;
    SELECT COALESCE(SUM(CASE WHEN pg.status_pagamento='A' THEN pg.valor_pagamento ELSE 0 END),0) INTO v_pago
    FROM cupom_fiscal c JOIN pagamento pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal WHERE c.id_pedido=OLD.id_pedido;
    IF OLD.baixa_estoque_realizada OR NOT NEW.baixa_estoque_realizada OR v_total<=0 OR v_pago<>v_total THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN26: baixa unica exige quitacao exata';
    END IF;
  END IF;
  IF NEW.status_preparo<>OLD.status_preparo THEN
    IF NOT ((OLD.status_preparo='RECEBIDO' AND NEW.status_preparo IN ('EM_PREPARO','CANCELADO'))
      OR (OLD.status_preparo='EM_PREPARO' AND NEW.status_preparo IN ('PRONTO','CANCELADO'))
      OR (OLD.status_preparo='PRONTO' AND NEW.status_preparo IN ('ENTREGUE','CANCELADO'))) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN17/RN18: transicao de preparo nao permitida';
    END IF;
  END IF;
  IF NEW.status_preparo IN ('EM_PREPARO','PRONTO','ENTREGUE') THEN
    SELECT COALESCE(SUM(quantidade*preco_unitario),0) INTO v_total FROM pedido_produto WHERE id_pedido=OLD.id_pedido;
    SELECT COALESCE(SUM(CASE WHEN pg.status_pagamento='A' THEN pg.valor_pagamento ELSE 0 END),0) INTO v_pago
    FROM cupom_fiscal c JOIN pagamento pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal WHERE c.id_pedido=OLD.id_pedido;
    IF v_total<=0 OR v_pago<>v_total OR NOT NEW.baixa_estoque_realizada THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN15: preparo ou entrega exigem quitacao exata';
    END IF;
  END IF;
END$$
CREATE TRIGGER trg_pedido_bd BEFORE DELETE ON pedido FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN23: cancelar o pedido sem apagar seu historico'; END$$

CREATE TRIGGER trg_cupom_bi BEFORE INSERT ON cupom_fiscal FOR EACH ROW
BEGIN
  DECLARE v_data DATETIME; DECLARE v_status VARCHAR(20);
  SELECT data_hora,status_preparo INTO v_data,v_status FROM pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
  IF NEW.data_hora_emissao<v_data OR v_status='CANCELADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN10/RN21: emissao deve respeitar o pedido';
  END IF;
END$$
CREATE TRIGGER trg_cupom_bu BEFORE UPDATE ON cupom_fiscal FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN20: cupom emitido e preservado'; END$$
CREATE TRIGGER trg_cupom_bd BEFORE DELETE ON cupom_fiscal FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN23: cupom permanece no historico'; END$$

CREATE TRIGGER trg_pagamento_bi BEFORE INSERT ON pagamento FOR EACH ROW
BEGIN
  DECLARE v_id INT UNSIGNED; DECLARE v_status VARCHAR(20); DECLARE v_data DATETIME; DECLARE v_emissao DATETIME; DECLARE v_total DECIMAL(18,2);
  SELECT id_pedido,data_hora_emissao INTO v_id,v_emissao FROM cupom_fiscal WHERE id_cupom_fiscal=NEW.id_cupom_fiscal;
  SELECT status_preparo,data_hora INTO v_status,v_data FROM pedido WHERE id_pedido=v_id FOR UPDATE;
  SELECT COALESCE(SUM(quantidade*preco_unitario),0) INTO v_total FROM pedido_produto WHERE id_pedido=v_id;
  IF v_status<>'RECEBIDO' OR v_total<=0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN05/RN18: tentativa exige pedido recebido e com produtos';
  END IF;
  IF NEW.status_pagamento NOT IN ('A','R') OR NEW.data_hora_pagamento<v_data OR NEW.data_hora_pagamento<v_emissao THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN12/RN21: tentativa inicial A ou R, posterior ao pedido';
  END IF;
END$$
CREATE TRIGGER trg_pagamento_bu BEFORE UPDATE ON pagamento FOR EACH ROW
BEGIN
  DECLARE v_id INT UNSIGNED; DECLARE v_status VARCHAR(20);
  SELECT id_pedido INTO v_id FROM cupom_fiscal WHERE id_cupom_fiscal=OLD.id_cupom_fiscal;
  SELECT status_preparo INTO v_status FROM pedido WHERE id_pedido=v_id FOR UPDATE;
  IF NEW.id_pagamento<>OLD.id_pagamento OR NEW.id_cupom_fiscal<>OLD.id_cupom_fiscal
     OR NEW.valor_pagamento<>OLD.valor_pagamento OR NEW.forma_pagamento<>OLD.forma_pagamento OR NEW.data_hora_pagamento<>OLD.data_hora_pagamento THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN20: dados da tentativa financeira sao imutaveis';
  END IF;
  IF NOT (OLD.status_pagamento='A' AND NEW.status_pagamento='E' AND v_status='CANCELADO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN19: estorno confirmado exige pagamento aprovado e pedido cancelado';
  END IF;
END$$
CREATE TRIGGER trg_pagamento_bd BEFORE DELETE ON pagamento FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN23: tentativas financeiras permanecem no historico'; END$$

-- RN24: recebimentos sao imutaveis; quantidade recebida aumenta o saldo.
CREATE TRIGGER trg_ep_ai AFTER INSERT ON entrada_produto FOR EACH ROW
BEGIN
  UPDATE produto SET quantidade_disponivel=quantidade_disponivel+NEW.quantidade_recebida,data_atualizacao=CURRENT_TIMESTAMP WHERE id_produto=NEW.id_produto;
END$$
CREATE TRIGGER trg_ep_bu BEFORE UPDATE ON entrada_produto FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN24: preservar recebimento confirmado'; END$$
CREATE TRIGGER trg_ep_bd BEFORE DELETE ON entrada_produto FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN24: preservar recebimento confirmado'; END$$
CREATE TRIGGER trg_entrada_bu BEFORE UPDATE ON entrada_estoque FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN24: preservar identificacao do recebimento'; END$$
CREATE TRIGGER trg_entrada_bd BEFORE DELETE ON entrada_estoque FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN24: recebimento permanece no historico'; END$$

-- Atualizacoes condicionais de saldo usam locks das linhas de PRODUTO.
-- A falha em qualquer produto aborta toda a aprovacao local e sua baixa.
CREATE PROCEDURE sp_baixar_estoque(IN p_id INT UNSIGNED)
BEGIN
  DECLARE v_fim BOOLEAN DEFAULT FALSE;
  DECLARE v_produto INT UNSIGNED; DECLARE v_quantidade INT UNSIGNED;
  DECLARE v_baixa BOOLEAN; DECLARE v_total DECIMAL(18,2); DECLARE v_pago DECIMAL(18,2);
  DECLARE cur CURSOR FOR SELECT id_produto,quantidade FROM pedido_produto WHERE id_pedido=p_id ORDER BY id_produto;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fim=TRUE;
  SELECT baixa_estoque_realizada INTO v_baixa FROM pedido WHERE id_pedido=p_id;
  SELECT COALESCE(SUM(quantidade*preco_unitario),0) INTO v_total FROM pedido_produto WHERE id_pedido=p_id;
  SELECT COALESCE(SUM(CASE WHEN pg.status_pagamento='A' THEN pg.valor_pagamento ELSE 0 END),0) INTO v_pago
  FROM cupom_fiscal c JOIN pagamento pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal WHERE c.id_pedido=p_id;
  IF NOT v_baixa AND v_total>0 AND v_pago=v_total THEN
    OPEN cur;
    baixar: LOOP
      FETCH cur INTO v_produto,v_quantidade;
      IF v_fim THEN LEAVE baixar; END IF;
      UPDATE produto SET quantidade_disponivel=quantidade_disponivel-v_quantidade,data_atualizacao=CURRENT_TIMESTAMP
      WHERE id_produto=v_produto AND quantidade_disponivel>=v_quantidade;
      IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN25/RN26: estoque insuficiente para quitacao'; END IF;
    END LOOP;
    CLOSE cur;
    UPDATE pedido SET baixa_estoque_realizada=TRUE WHERE id_pedido=p_id;
  END IF;
END$$
CREATE TRIGGER trg_pagamento_ai AFTER INSERT ON pagamento FOR EACH ROW
BEGIN
  DECLARE v_id INT UNSIGNED;
  SELECT id_pedido INTO v_id FROM cupom_fiscal WHERE id_cupom_fiscal=NEW.id_cupom_fiscal;
  CALL sp_baixar_estoque(v_id);
END$$

CREATE PROCEDURE sp_registrar_entrada(IN p_fornecedor INT UNSIGNED,IN p_data DATETIME,IN p_produtos JSON,OUT p_id INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  IF p_produtos IS NULL OR JSON_TYPE(p_produtos)<>'ARRAY' OR JSON_LENGTH(p_produtos)=0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN24: entrada deve conter ao menos um produto';
  END IF;
  IF EXISTS(SELECT 1 FROM JSON_TABLE(p_produtos,'$[*]' COLUMNS(qtd VARCHAR(100) PATH '$.quantidade_recebida' ERROR ON EMPTY ERROR ON ERROR)) j
    WHERE NOT REGEXP_LIKE(qtd,'^[1-9][0-9]*$')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN24: quantidade recebida deve ser inteira e positiva';
  END IF;
  START TRANSACTION;
  INSERT INTO entrada_estoque(id_fornecedor,data_hora) VALUES(p_fornecedor,COALESCE(p_data,CURRENT_TIMESTAMP));
  SET p_id=LAST_INSERT_ID();
  INSERT INTO entrada_produto(id_entrada_estoque,id_produto,quantidade_recebida)
  SELECT p_id,j.id_produto,j.quantidade_recebida FROM JSON_TABLE(p_produtos,'$[*]' COLUMNS(
    id_produto INT UNSIGNED PATH '$.id_produto' ERROR ON EMPTY ERROR ON ERROR,
    quantidade_recebida INT UNSIGNED PATH '$.quantidade_recebida' ERROR ON EMPTY ERROR ON ERROR)) j;
  COMMIT;
END$$

-- RN05/RN10/RN11: publicar pedido completo em uma transacao.
-- A01-A03 detectam SQL administrativo que ignore a rotina.
CREATE PROCEDURE sp_criar_pedido(
  IN p_cliente INT UNSIGNED,IN p_funcionario INT UNSIGNED,IN p_origem CHAR(1),
  IN p_totem VARCHAR(50),IN p_comanda VARCHAR(120),IN p_data DATETIME,
  IN p_numero_cupom VARCHAR(50),IN p_itens JSON,IN p_pagamentos JSON,
  OUT p_id_pedido INT UNSIGNED)
BEGIN
  DECLARE v_id_cupom INT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  IF p_itens IS NULL OR JSON_TYPE(p_itens)<>'ARRAY' OR JSON_LENGTH(p_itens)=0
     OR p_pagamentos IS NULL OR JSON_TYPE(p_pagamentos)<>'ARRAY' OR JSON_LENGTH(p_pagamentos)=0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN05/RN11: informar produtos e ao menos uma tentativa';
  END IF;
  IF EXISTS(SELECT 1 FROM JSON_TABLE(p_itens,'$[*]' COLUMNS(
    quantidade VARCHAR(100) PATH '$.quantidade' ERROR ON EMPTY ERROR ON ERROR,
    preco VARCHAR(100) PATH '$.preco_unitario' ERROR ON EMPTY ERROR ON ERROR)) j
    WHERE NOT REGEXP_LIKE(quantidade,'^[1-9][0-9]*$') OR NOT REGEXP_LIKE(preco,'^[0-9]+([.][0-9]{1,2})?$')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN05/RN06: quantidade inteira e preco em centavos';
  END IF;
  IF EXISTS(SELECT 1 FROM JSON_TABLE(p_pagamentos,'$[*]' COLUMNS(
    valor VARCHAR(100) PATH '$.valor_pagamento' ERROR ON EMPTY ERROR ON ERROR)) j
    WHERE NOT REGEXP_LIKE(valor,'^[0-9]+([.][0-9]{1,2})?$')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN13: valor do pagamento deve usar centavos';
  END IF;
  START TRANSACTION;
  INSERT INTO pedido(id_cliente,id_funcionario,origem_pedido,totem,nome_comanda,data_hora)
  VALUES(p_cliente,p_funcionario,p_origem,p_totem,p_comanda,COALESCE(p_data,CURRENT_TIMESTAMP));
  SET p_id_pedido=LAST_INSERT_ID();
  INSERT INTO pedido_produto(id_pedido,id_produto,quantidade,preco_unitario)
  SELECT p_id_pedido,j.id_produto,j.quantidade,j.preco_unitario
  FROM JSON_TABLE(p_itens,'$[*]' COLUMNS(
    id_produto INT UNSIGNED PATH '$.id_produto' ERROR ON EMPTY ERROR ON ERROR,
    quantidade INT UNSIGNED PATH '$.quantidade' ERROR ON EMPTY ERROR ON ERROR,
    preco_unitario DECIMAL(10,2) PATH '$.preco_unitario' ERROR ON EMPTY ERROR ON ERROR)) j;
  INSERT INTO cupom_fiscal(id_pedido,numero,data_hora_emissao) VALUES(p_id_pedido,p_numero_cupom,COALESCE(p_data,CURRENT_TIMESTAMP));
  SET v_id_cupom=LAST_INSERT_ID();
  INSERT INTO pagamento(id_cupom_fiscal,forma_pagamento,valor_pagamento,status_pagamento,data_hora_pagamento)
  SELECT v_id_cupom,j.forma_pagamento,j.valor_pagamento,j.status_pagamento,COALESCE(p_data,CURRENT_TIMESTAMP)
  FROM JSON_TABLE(p_pagamentos,'$[*]' COLUMNS(
    forma_pagamento CHAR(1) PATH '$.forma_pagamento' ERROR ON EMPTY ERROR ON ERROR,
    valor_pagamento DECIMAL(10,2) PATH '$.valor_pagamento' ERROR ON EMPTY ERROR ON ERROR,
    status_pagamento CHAR(1) PATH '$.status_pagamento' ERROR ON EMPTY ERROR ON ERROR)) j;
  COMMIT;
END$$

CREATE PROCEDURE sp_cancelar_pedido(IN p_id INT UNSIGNED)
BEGIN
  DECLARE v_status VARCHAR(20); DECLARE v_baixa BOOLEAN;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT status_preparo,baixa_estoque_realizada INTO v_status,v_baixa FROM pedido WHERE id_pedido=p_id FOR UPDATE;
  UPDATE pedido SET status_preparo='CANCELADO' WHERE id_pedido=p_id;
  IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='RN18: pedido inexistente ou ja cancelado'; END IF;
  -- RN27: antes do preparo, devolver integralmente as unidades baixadas.
  -- Apos iniciar preparo, a devolucao exige confirmacao fisica por item.
  IF v_status='RECEBIDO' AND v_baixa THEN
    UPDATE pedido_produto SET quantidade_devolvida=quantidade WHERE id_pedido=p_id;
  END IF;
  COMMIT;
END$$
DELIMITER ;

-- Carga inteiramente ficticia. 120 pedidos: escolha pedagogica, volume real pendente.

INSERT INTO cliente(nome,cpf_cnpj) VALUES
('Cliente ficticio 01','00000000001'),
('Cliente ficticio 02',NULL),
('Cliente ficticio 03','00000000003'),
('Cliente ficticio 04',NULL),
('Cliente ficticio 05','00000000005'),
('Cliente ficticio 06',NULL),
('Cliente ficticio 07','00000000007'),
('Cliente ficticio 08',NULL),
('Cliente ficticio 09','00000000009'),
('Cliente ficticio 10',NULL),
('Cliente ficticio 11','00000000011'),
('Cliente ficticio 12',NULL),
('Cliente ficticio 13','00000000013'),
('Cliente ficticio 14',NULL),
('Cliente ficticio 15','00000000015'),
('Cliente ficticio 16',NULL),
('Cliente ficticio 17','00000000017'),
('Cliente ficticio 18',NULL),
('Cliente ficticio 19','00000000019'),
('Cliente ficticio 20',NULL);
INSERT INTO funcionario(nome,cargo) VALUES
('Funcionario ficticio 1','Gerencia demonstrativa'),
('Funcionario ficticio 2','Atendimento demonstrativo'),
('Funcionario ficticio 3','Atendimento demonstrativo'),
('Funcionario ficticio 4','Atendimento demonstrativo'),
('Funcionario ficticio 5','Atendimento demonstrativo'),
('Funcionario ficticio 6','Atendimento demonstrativo');
INSERT INTO fornecedor(cnpj) VALUES ('00000000000100'),('00000000000200');
INSERT INTO produto(nome,preco,estoque_minimo) VALUES
('Espresso demonstrativo',8.50,100),
('Cappuccino demonstrativo',14.00,100),
('Latte demonstrativo',16.00,100),
('Cha demonstrativo',11.00,20),
('Chocolate demonstrativo',18.00,20),
('Croissant demonstrativo',15.00,20),
('Pao de queijo demonstrativo',9.00,20),
('Bolo demonstrativo',19.00,20),
('Sanduiche demonstrativo',22.00,20),
('Cookie demonstrativo',10.00,20),
('Suco demonstrativo',13.00,20),
('Agua demonstrativa',6.00,20);
CALL sp_registrar_entrada(1,'2026-06-30 08:00:00','[{"id_produto":1,"quantidade_recebida":100},{"id_produto":2,"quantidade_recebida":100},{"id_produto":3,"quantidade_recebida":100},{"id_produto":4,"quantidade_recebida":100},{"id_produto":5,"quantidade_recebida":100},{"id_produto":6,"quantidade_recebida":100}]',@entrada);
CALL sp_registrar_entrada(2,'2026-06-30 08:00:00','[{"id_produto":7,"quantidade_recebida":100},{"id_produto":8,"quantidade_recebida":100},{"id_produto":9,"quantidade_recebida":100},{"id_produto":10,"quantidade_recebida":100},{"id_produto":11,"quantidade_recebida":100},{"id_produto":12,"quantidade_recebida":100}]',@entrada);

-- Pedido ficticio 1 | entregue
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 1','2026-07-01 09:01:00','DEMO-2026-000001','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 2 | entregue
CALL sp_criar_pedido(3,3,'B',NULL,'Chamada ficticia 2','2026-07-02 10:02:00','DEMO-2026-000002','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 3 | entregue
CALL sp_criar_pedido(4,NULL,'D',NULL,'Chamada ficticia 3','2026-07-03 11:03:00','DEMO-2026-000003','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 4 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 4','2026-07-04 12:04:00','DEMO-2026-000004','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 5 | entregue
CALL sp_criar_pedido(6,6,'B',NULL,NULL,'2026-07-05 13:05:00','DEMO-2026-000005','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 6 | entregue
CALL sp_criar_pedido(7,NULL,'D',NULL,'Chamada ficticia 6','2026-07-06 14:06:00','DEMO-2026-000006','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 7 | entregue
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 7','2026-07-07 15:07:00','DEMO-2026-000007','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"R"},{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 8 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 8','2026-07-08 16:08:00','DEMO-2026-000008','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 9 | entregue
CALL sp_criar_pedido(10,NULL,'D',NULL,'Chamada ficticia 9','2026-07-09 17:09:00','DEMO-2026-000009','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 10 | entregue
CALL sp_criar_pedido(11,NULL,'T','TOTEM-DEMO-1',NULL,'2026-07-10 18:10:00','DEMO-2026-000010','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 11 | entregue
CALL sp_criar_pedido(12,6,'B',NULL,'Chamada ficticia 11','2026-07-11 09:11:00','DEMO-2026-000011','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 12 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 12','2026-07-12 10:12:00','DEMO-2026-000012','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 13 | entregue
CALL sp_criar_pedido(14,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 13','2026-07-13 11:13:00','DEMO-2026-000013','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 14 | entregue
CALL sp_criar_pedido(15,3,'B',NULL,'Chamada ficticia 14','2026-07-14 12:14:00','DEMO-2026-000014','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"R"},{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 15 | entregue
CALL sp_criar_pedido(16,NULL,'D',NULL,NULL,'2026-07-15 13:15:00','DEMO-2026-000015','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 16 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 16','2026-07-16 14:16:00','DEMO-2026-000016','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 17 | entregue
CALL sp_criar_pedido(18,6,'B',NULL,'Chamada ficticia 17','2026-07-17 15:17:00','DEMO-2026-000017','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 18 | entregue
CALL sp_criar_pedido(1,NULL,'D',NULL,'Chamada ficticia 18','2026-07-18 16:18:00','DEMO-2026-000018','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 19 | entregue
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 19','2026-07-19 17:19:00','DEMO-2026-000019','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 20 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,NULL,'2026-07-20 18:20:00','DEMO-2026-000020','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 21 | entregue
CALL sp_criar_pedido(4,NULL,'D',NULL,'Chamada ficticia 21','2026-07-21 09:21:00','DEMO-2026-000021','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 22 | entregue
CALL sp_criar_pedido(5,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 22','2026-07-22 10:22:00','DEMO-2026-000022','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 23 | entregue
CALL sp_criar_pedido(6,6,'B',NULL,'Chamada ficticia 23','2026-07-23 11:23:00','DEMO-2026-000023','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 24 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 24','2026-07-24 12:24:00','DEMO-2026-000024','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 25 | entregue
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2',NULL,'2026-07-25 13:25:00','DEMO-2026-000025','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 26 | entregue
CALL sp_criar_pedido(9,3,'B',NULL,'Chamada ficticia 26','2026-07-26 14:26:00','DEMO-2026-000026','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 27 | entregue
CALL sp_criar_pedido(10,NULL,'D',NULL,'Chamada ficticia 27','2026-07-27 15:27:00','DEMO-2026-000027','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 28 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 28','2026-07-01 16:28:00','DEMO-2026-000028','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"R"},{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 29 | em_preparo
CALL sp_criar_pedido(12,6,'B',NULL,'Chamada ficticia 29','2026-07-02 17:29:00','DEMO-2026-000029','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;

-- Pedido ficticio 30 | em_preparo
CALL sp_criar_pedido(13,NULL,'D',NULL,NULL,'2026-07-03 18:30:00','DEMO-2026-000030','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;

-- Pedido ficticio 31 | pronto
CALL sp_criar_pedido(14,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 31','2026-07-04 09:31:00','DEMO-2026-000031','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;

-- Pedido ficticio 32 | pronto
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 32','2026-07-05 10:32:00','DEMO-2026-000032','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;

-- Pedido ficticio 33 | recusado
CALL sp_criar_pedido(16,NULL,'D',NULL,'Chamada ficticia 33','2026-07-06 11:33:00','DEMO-2026-000033','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":52.5,"status_pagamento":"R"}]',@pedido);

-- Pedido ficticio 34 | recusado
CALL sp_criar_pedido(17,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 34','2026-07-07 12:34:00','DEMO-2026-000034','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"R"}]',@pedido);

-- Pedido ficticio 35 | parcial
CALL sp_criar_pedido(18,6,'B',NULL,NULL,'2026-07-08 13:35:00','DEMO-2026-000035','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":21,"status_pagamento":"A"}]',@pedido);

-- Pedido ficticio 36 | parcial
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 36','2026-07-09 14:36:00','DEMO-2026-000036','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);

-- Pedido ficticio 37 | cancelado_recusado
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 37','2026-07-10 15:37:00','DEMO-2026-000037','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"R"}]',@pedido);
CALL sp_cancelar_pedido(@pedido);

-- Pedido ficticio 38 | cancelado_apos_preparo
CALL sp_criar_pedido(3,3,'B',NULL,'Chamada ficticia 38','2026-07-11 16:38:00','DEMO-2026-000038','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
CALL sp_cancelar_pedido(@pedido);

-- Pedido ficticio 39 | cancelado_estornado
CALL sp_criar_pedido(4,NULL,'D',NULL,'Chamada ficticia 39','2026-07-12 17:39:00','DEMO-2026-000039','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
CALL sp_cancelar_pedido(@pedido);
UPDATE pagamento pg JOIN cupom_fiscal c ON c.id_cupom_fiscal=pg.id_cupom_fiscal SET pg.status_pagamento='E' WHERE c.id_pedido=@pedido AND pg.status_pagamento='A';

-- Pedido ficticio 40 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1',NULL,'2026-07-13 18:40:00','DEMO-2026-000040','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;
CALL sp_registrar_entrada(1,'2026-08-01 08:00:00','[{"id_produto":1,"quantidade_recebida":10},{"id_produto":2,"quantidade_recebida":10}]',@entrada);

-- Pedido ficticio 41 | entregue
CALL sp_criar_pedido(6,6,'B',NULL,'Chamada ficticia 41','2026-08-01 09:41:00','DEMO-2026-000041','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 42 | entregue
CALL sp_criar_pedido(7,NULL,'D',NULL,'Chamada ficticia 42','2026-08-02 10:42:00','DEMO-2026-000042','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 43 | entregue
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 43','2026-08-03 11:43:00','DEMO-2026-000043','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 44 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 44','2026-08-04 12:44:00','DEMO-2026-000044','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 45 | entregue
CALL sp_criar_pedido(10,NULL,'D',NULL,NULL,'2026-08-05 13:45:00','DEMO-2026-000045','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 46 | entregue
CALL sp_criar_pedido(11,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 46','2026-08-06 14:46:00','DEMO-2026-000046','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 47 | entregue
CALL sp_criar_pedido(12,6,'B',NULL,'Chamada ficticia 47','2026-08-07 15:47:00','DEMO-2026-000047','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 48 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 48','2026-08-08 16:48:00','DEMO-2026-000048','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 49 | entregue
CALL sp_criar_pedido(14,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 49','2026-08-09 17:49:00','DEMO-2026-000049','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"R"},{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 50 | entregue
CALL sp_criar_pedido(15,3,'B',NULL,NULL,'2026-08-10 18:50:00','DEMO-2026-000050','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 51 | entregue
CALL sp_criar_pedido(16,NULL,'D',NULL,'Chamada ficticia 51','2026-08-11 09:51:00','DEMO-2026-000051','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 52 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 52','2026-08-12 10:52:00','DEMO-2026-000052','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 53 | entregue
CALL sp_criar_pedido(18,6,'B',NULL,'Chamada ficticia 53','2026-08-13 11:53:00','DEMO-2026-000053','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 54 | entregue
CALL sp_criar_pedido(1,NULL,'D',NULL,'Chamada ficticia 54','2026-08-14 12:54:00','DEMO-2026-000054','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 55 | entregue
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2',NULL,'2026-08-15 13:55:00','DEMO-2026-000055','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 56 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 56','2026-08-16 14:56:00','DEMO-2026-000056','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"R"},{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 57 | entregue
CALL sp_criar_pedido(4,NULL,'D',NULL,'Chamada ficticia 57','2026-08-17 15:57:00','DEMO-2026-000057','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 58 | entregue
CALL sp_criar_pedido(5,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 58','2026-08-18 16:58:00','DEMO-2026-000058','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 59 | entregue
CALL sp_criar_pedido(6,6,'B',NULL,'Chamada ficticia 59','2026-08-19 17:59:00','DEMO-2026-000059','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 60 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,NULL,'2026-08-20 18:00:00','DEMO-2026-000060','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 61 | entregue
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 61','2026-08-21 09:01:00','DEMO-2026-000061','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 62 | entregue
CALL sp_criar_pedido(9,3,'B',NULL,'Chamada ficticia 62','2026-08-22 10:02:00','DEMO-2026-000062','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 63 | entregue
CALL sp_criar_pedido(10,NULL,'D',NULL,'Chamada ficticia 63','2026-08-23 11:03:00','DEMO-2026-000063','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 64 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 64','2026-08-24 12:04:00','DEMO-2026-000064','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 65 | entregue
CALL sp_criar_pedido(12,6,'B',NULL,NULL,'2026-08-25 13:05:00','DEMO-2026-000065','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 66 | entregue
CALL sp_criar_pedido(13,NULL,'D',NULL,'Chamada ficticia 66','2026-08-26 14:06:00','DEMO-2026-000066','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 67 | entregue
CALL sp_criar_pedido(14,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 67','2026-08-27 15:07:00','DEMO-2026-000067','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 68 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 68','2026-08-01 16:08:00','DEMO-2026-000068','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 69 | em_preparo
CALL sp_criar_pedido(16,NULL,'D',NULL,'Chamada ficticia 69','2026-08-02 17:09:00','DEMO-2026-000069','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;

-- Pedido ficticio 70 | em_preparo
CALL sp_criar_pedido(17,NULL,'T','TOTEM-DEMO-1',NULL,'2026-08-03 18:10:00','DEMO-2026-000070','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"R"},{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;

-- Pedido ficticio 71 | pronto
CALL sp_criar_pedido(18,6,'B',NULL,'Chamada ficticia 71','2026-08-04 09:11:00','DEMO-2026-000071','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;

-- Pedido ficticio 72 | pronto
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 72','2026-08-05 10:12:00','DEMO-2026-000072','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;

-- Pedido ficticio 73 | recusado
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 73','2026-08-06 11:13:00','DEMO-2026-000073','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"R"}]',@pedido);

-- Pedido ficticio 74 | recusado
CALL sp_criar_pedido(3,3,'B',NULL,'Chamada ficticia 74','2026-08-07 12:14:00','DEMO-2026-000074','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"R"}]',@pedido);

-- Pedido ficticio 75 | parcial
CALL sp_criar_pedido(4,NULL,'D',NULL,NULL,'2026-08-08 13:15:00','DEMO-2026-000075','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);

-- Pedido ficticio 76 | parcial
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 76','2026-08-09 14:16:00','DEMO-2026-000076','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":27.5,"status_pagamento":"A"}]',@pedido);

-- Pedido ficticio 77 | cancelado_recusado
CALL sp_criar_pedido(6,6,'B',NULL,'Chamada ficticia 77','2026-08-10 15:17:00','DEMO-2026-000077','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"R"}]',@pedido);
CALL sp_cancelar_pedido(@pedido);

-- Pedido ficticio 78 | cancelado_apos_preparo
CALL sp_criar_pedido(7,NULL,'D',NULL,'Chamada ficticia 78','2026-08-11 16:18:00','DEMO-2026-000078','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
CALL sp_cancelar_pedido(@pedido);
UPDATE pedido_produto SET quantidade_devolvida=1 WHERE id_pedido=@pedido AND id_produto=6;

-- Pedido ficticio 79 | cancelado_estornado
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 79','2026-08-12 17:19:00','DEMO-2026-000079','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
CALL sp_cancelar_pedido(@pedido);
UPDATE pagamento pg JOIN cupom_fiscal c ON c.id_cupom_fiscal=pg.id_cupom_fiscal SET pg.status_pagamento='E' WHERE c.id_pedido=@pedido AND pg.status_pagamento='A';

-- Pedido ficticio 80 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,NULL,'2026-08-13 18:20:00','DEMO-2026-000080','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 81 | entregue
CALL sp_criar_pedido(10,NULL,'D',NULL,'Chamada ficticia 81','2026-09-01 09:21:00','DEMO-2026-000081','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 82 | entregue
CALL sp_criar_pedido(11,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 82','2026-09-02 10:22:00','DEMO-2026-000082','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 83 | entregue
CALL sp_criar_pedido(12,6,'B',NULL,'Chamada ficticia 83','2026-09-03 11:23:00','DEMO-2026-000083','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 84 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 84','2026-09-04 12:24:00','DEMO-2026-000084','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 85 | entregue
CALL sp_criar_pedido(14,NULL,'T','TOTEM-DEMO-2',NULL,'2026-09-05 13:25:00','DEMO-2026-000085','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 86 | entregue
CALL sp_criar_pedido(15,3,'B',NULL,'Chamada ficticia 86','2026-09-06 14:26:00','DEMO-2026-000086','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 87 | entregue
CALL sp_criar_pedido(16,NULL,'D',NULL,'Chamada ficticia 87','2026-09-07 15:27:00','DEMO-2026-000087','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 88 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 88','2026-09-08 16:28:00','DEMO-2026-000088','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 89 | entregue
CALL sp_criar_pedido(18,6,'B',NULL,'Chamada ficticia 89','2026-09-09 17:29:00','DEMO-2026-000089','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 90 | entregue
CALL sp_criar_pedido(1,NULL,'D',NULL,NULL,'2026-09-10 18:30:00','DEMO-2026-000090','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 91 | entregue
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 91','2026-09-11 09:31:00','DEMO-2026-000091','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"R"},{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 92 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 92','2026-09-12 10:32:00','DEMO-2026-000092','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 93 | entregue
CALL sp_criar_pedido(4,NULL,'D',NULL,'Chamada ficticia 93','2026-09-13 11:33:00','DEMO-2026-000093','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 94 | entregue
CALL sp_criar_pedido(5,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 94','2026-09-14 12:34:00','DEMO-2026-000094','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 95 | entregue
CALL sp_criar_pedido(6,6,'B',NULL,NULL,'2026-09-15 13:35:00','DEMO-2026-000095','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 96 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 96','2026-09-16 14:36:00','DEMO-2026-000096','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 97 | entregue
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 97','2026-09-17 15:37:00','DEMO-2026-000097','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 98 | entregue
CALL sp_criar_pedido(9,3,'B',NULL,'Chamada ficticia 98','2026-09-18 16:38:00','DEMO-2026-000098','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"R"},{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 99 | entregue
CALL sp_criar_pedido(10,NULL,'D',NULL,'Chamada ficticia 99','2026-09-19 17:39:00','DEMO-2026-000099','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 100 | entregue
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1',NULL,'2026-09-20 18:40:00','DEMO-2026-000100','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 101 | entregue
CALL sp_criar_pedido(12,6,'B',NULL,'Chamada ficticia 101','2026-09-21 09:41:00','DEMO-2026-000101','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 102 | entregue
CALL sp_criar_pedido(13,NULL,'D',NULL,'Chamada ficticia 102','2026-09-22 10:42:00','DEMO-2026-000102','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":17.5,"status_pagamento":"A"},{"forma_pagamento":"X","valor_pagamento":17.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 103 | entregue
CALL sp_criar_pedido(14,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 103','2026-09-23 11:43:00','DEMO-2026-000103','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":31,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 104 | entregue
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 104','2026-09-24 12:44:00','DEMO-2026-000104','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 105 | entregue
CALL sp_criar_pedido(16,NULL,'D',NULL,NULL,'2026-09-25 13:45:00','DEMO-2026-000105','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":26.25,"status_pagamento":"A"},{"forma_pagamento":"D","valor_pagamento":26.25,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 106 | entregue
CALL sp_criar_pedido(17,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 106','2026-09-26 14:46:00','DEMO-2026-000106','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 107 | entregue
CALL sp_criar_pedido(18,6,'B',NULL,'Chamada ficticia 107','2026-09-27 15:47:00','DEMO-2026-000107','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 108 | entregue
CALL sp_criar_pedido(NULL,NULL,'D',NULL,'Chamada ficticia 108','2026-09-01 16:48:00','DEMO-2026-000108','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":23.5,"status_pagamento":"A"},{"forma_pagamento":"C","valor_pagamento":23.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='ENTREGUE' WHERE id_pedido=@pedido;

-- Pedido ficticio 109 | em_preparo
CALL sp_criar_pedido(2,NULL,'T','TOTEM-DEMO-2','Chamada ficticia 109','2026-09-02 17:49:00','DEMO-2026-000109','[{"id_produto":1,"quantidade":2,"preco_unitario":8.5},{"id_produto":5,"quantidade":1,"preco_unitario":18}]','[{"forma_pagamento":"C","valor_pagamento":35,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;

-- Pedido ficticio 110 | em_preparo
CALL sp_criar_pedido(3,3,'B',NULL,NULL,'2026-09-03 18:50:00','DEMO-2026-000110','[{"id_produto":2,"quantidade":1,"preco_unitario":14},{"id_produto":6,"quantidade":2,"preco_unitario":15}]','[{"forma_pagamento":"D","valor_pagamento":44,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;

-- Pedido ficticio 111 | pronto
CALL sp_criar_pedido(4,NULL,'D',NULL,'Chamada ficticia 111','2026-09-04 09:51:00','DEMO-2026-000111','[{"id_produto":3,"quantidade":2,"preco_unitario":16},{"id_produto":7,"quantidade":1,"preco_unitario":9}]','[{"forma_pagamento":"X","valor_pagamento":20.5,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":20.5,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;

-- Pedido ficticio 112 | pronto
CALL sp_criar_pedido(NULL,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 112','2026-09-05 10:52:00','DEMO-2026-000112','[{"id_produto":4,"quantidade":1,"preco_unitario":11},{"id_produto":8,"quantidade":2,"preco_unitario":19},{"id_produto":12,"quantidade":1,"preco_unitario":6}]','[{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"R"},{"forma_pagamento":"P","valor_pagamento":55,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
UPDATE pedido SET status_preparo='PRONTO' WHERE id_pedido=@pedido;

-- Pedido ficticio 113 | recusado
CALL sp_criar_pedido(6,6,'B',NULL,'Chamada ficticia 113','2026-09-06 11:53:00','DEMO-2026-000113','[{"id_produto":5,"quantidade":2,"preco_unitario":18},{"id_produto":9,"quantidade":1,"preco_unitario":22}]','[{"forma_pagamento":"C","valor_pagamento":58,"status_pagamento":"R"}]',@pedido);

-- Pedido ficticio 114 | recusado
CALL sp_criar_pedido(7,NULL,'D',NULL,'Chamada ficticia 114','2026-09-07 12:54:00','DEMO-2026-000114','[{"id_produto":6,"quantidade":1,"preco_unitario":15},{"id_produto":10,"quantidade":2,"preco_unitario":10}]','[{"forma_pagamento":"D","valor_pagamento":35,"status_pagamento":"R"}]',@pedido);

-- Pedido ficticio 115 | parcial
CALL sp_criar_pedido(8,NULL,'T','TOTEM-DEMO-2',NULL,'2026-09-08 13:55:00','DEMO-2026-000115','[{"id_produto":7,"quantidade":2,"preco_unitario":9},{"id_produto":11,"quantidade":1,"preco_unitario":13}]','[{"forma_pagamento":"X","valor_pagamento":15.5,"status_pagamento":"A"}]',@pedido);

-- Pedido ficticio 116 | parcial
CALL sp_criar_pedido(NULL,3,'B',NULL,'Chamada ficticia 116','2026-09-09 14:56:00','DEMO-2026-000116','[{"id_produto":8,"quantidade":1,"preco_unitario":19},{"id_produto":12,"quantidade":2,"preco_unitario":6},{"id_produto":4,"quantidade":1,"preco_unitario":11}]','[{"forma_pagamento":"P","valor_pagamento":21,"status_pagamento":"A"}]',@pedido);

-- Pedido ficticio 117 | cancelado_recusado
CALL sp_criar_pedido(10,NULL,'D',NULL,'Chamada ficticia 117','2026-09-10 15:57:00','DEMO-2026-000117','[{"id_produto":9,"quantidade":2,"preco_unitario":22},{"id_produto":1,"quantidade":1,"preco_unitario":8.5}]','[{"forma_pagamento":"C","valor_pagamento":52.5,"status_pagamento":"R"}]',@pedido);
CALL sp_cancelar_pedido(@pedido);

-- Pedido ficticio 118 | cancelado_apos_preparo
CALL sp_criar_pedido(11,NULL,'T','TOTEM-DEMO-1','Chamada ficticia 118','2026-09-11 16:58:00','DEMO-2026-000118','[{"id_produto":10,"quantidade":1,"preco_unitario":10},{"id_produto":2,"quantidade":2,"preco_unitario":14}]','[{"forma_pagamento":"D","valor_pagamento":38,"status_pagamento":"A"}]',@pedido);
UPDATE pedido SET status_preparo='EM_PREPARO' WHERE id_pedido=@pedido;
CALL sp_cancelar_pedido(@pedido);

-- Pedido ficticio 119 | cancelado_estornado
CALL sp_criar_pedido(12,6,'B',NULL,'Chamada ficticia 119','2026-09-12 17:59:00','DEMO-2026-000119','[{"id_produto":11,"quantidade":2,"preco_unitario":13},{"id_produto":3,"quantidade":1,"preco_unitario":16}]','[{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"R"},{"forma_pagamento":"X","valor_pagamento":42,"status_pagamento":"A"}]',@pedido);
CALL sp_cancelar_pedido(@pedido);
UPDATE pagamento pg JOIN cupom_fiscal c ON c.id_cupom_fiscal=pg.id_cupom_fiscal SET pg.status_pagamento='E' WHERE c.id_pedido=@pedido AND pg.status_pagamento='A';

-- Pedido ficticio 120 | divergencia
CALL sp_criar_pedido(NULL,NULL,'D',NULL,NULL,'2026-09-13 18:00:00','DEMO-2026-000120','[{"id_produto":12,"quantidade":1,"preco_unitario":6},{"id_produto":4,"quantidade":2,"preco_unitario":11},{"id_produto":8,"quantidade":1,"preco_unitario":19}]','[{"forma_pagamento":"P","valor_pagamento":47,"status_pagamento":"A"},{"forma_pagamento":"P","valor_pagamento":0.01,"status_pagamento":"A"}]',@pedido);

-- 4. SELECT com JOIN: comanda e produtos sem multiplicar pagamentos.
SELECT p.id_pedido,COALESCE(p.nome_comanda,CAST(p.id_pedido AS CHAR)) AS comanda,
       pr.nome,pp.quantidade,pp.preco_unitario
FROM pedido p JOIN pedido_produto pp ON pp.id_pedido=p.id_pedido
JOIN produto pr ON pr.id_produto=pp.id_produto WHERE p.id_pedido=1;

-- 5. UPDATE: reajuste no cadastro nao altera o preco historico de vendas.
-- ROLLBACK mantem a massa de demonstracao reproduzivel.
START TRANSACTION;
UPDATE produto SET preco=preco+1.00 WHERE id_produto=1;
SELECT pr.id_produto,pr.preco AS preco_atual,pp.preco_unitario AS preco_da_venda
FROM produto pr JOIN pedido_produto pp ON pp.id_produto=pr.id_produto WHERE pr.id_produto=1 LIMIT 3;
ROLLBACK;

-- 6. DELETE: exemplo com cadastro de teste sem vinculos; historico nao e apagado.
START TRANSACTION;
INSERT INTO produto(nome,preco) VALUES('Cadastro descartavel de teste',1.00);
SET @produto_descartavel=LAST_INSERT_ID();
DELETE FROM produto WHERE id_produto=@produto_descartavel;
SELECT COUNT(*) AS cadastros_descartaveis_restantes FROM produto WHERE id_produto=@produto_descartavel;
ROLLBACK;

-- 7. Gerenciais. Periodo inclui o inicio e exclui o inicio do mes seguinte.
SET @inicio='2026-07-01 00:00:00'; SET @fim='2026-10-01 00:00:00';

-- G01 - Qual o valor de vendas quitadas e o ticket medio de cada mes?
-- Atende: P1; KPI01 (vendas quitadas), KPI02 (ticket medio).
SELECT DATE_FORMAT(data_hora,'%Y-%m') AS mes,COUNT(*) AS pedidos_quitados,
       SUM(valor_total) AS vendas_quitadas,ROUND(AVG(valor_total),2) AS ticket_medio
FROM vw_situacao_pedido WHERE data_hora>=@inicio AND data_hora<@fim AND situacao_financeira='QUITADO'
GROUP BY DATE_FORMAT(data_hora,'%Y-%m') ORDER BY mes;

-- G02 - Quais produtos vendem mais nos pedidos quitados?
-- Atende: P1; KPI03 (unidades vendidas por produto).
SELECT pr.id_produto,pr.nome,SUM(pp.quantidade) AS unidades_vendidas,
       SUM(pp.quantidade*pp.preco_unitario) AS valor_vendido
FROM pedido_produto pp JOIN produto pr ON pr.id_produto=pp.id_produto
JOIN vw_situacao_pedido s ON s.id_pedido=pp.id_pedido
WHERE s.data_hora>=@inicio AND s.data_hora<@fim AND s.situacao_financeira='QUITADO'
GROUP BY pr.id_produto,pr.nome ORDER BY unidades_vendidas DESC,pr.id_produto;

-- G03 - Qual a participacao de cada origem nas vendas quitadas?
-- Atende: P1; KPI04 (participacao por canal).
SELECT origem_pedido,COUNT(*) AS pedidos,SUM(valor_total) AS valor_vendido,
       ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) AS participacao_percentual
FROM vw_situacao_pedido WHERE data_hora>=@inicio AND data_hora<@fim AND situacao_financeira='QUITADO'
GROUP BY origem_pedido ORDER BY origem_pedido;

-- G04 - Qual a taxa de cancelamento mensal?
-- Atende: P1; KPI05 (pedidos cancelados/registrados).
SELECT DATE_FORMAT(data_hora,'%Y-%m') AS mes,COUNT(*) AS registrados,
       SUM(status_preparo='CANCELADO') AS cancelados,
       ROUND(100.0*SUM(status_preparo='CANCELADO')/COUNT(*),2) AS taxa_cancelamento
FROM pedido WHERE data_hora>=@inicio AND data_hora<@fim GROUP BY DATE_FORMAT(data_hora,'%Y-%m') ORDER BY mes;

-- G05 - Quanto permanece aprovado em pedidos cancelados, aguardando devolucao?
-- Atende: P1; KPI06 (valor pendente de devolucao).
SELECT DATE_FORMAT(data_hora,'%Y-%m') AS mes,SUM(devolucao_pendente) AS devolucao_pendente,
       SUM(situacao_financeira='DIVERGENCIA') AS pedidos_com_divergencia
FROM vw_situacao_pedido WHERE data_hora>=@inicio AND data_hora<@fim GROUP BY DATE_FORMAT(data_hora,'%Y-%m') ORDER BY mes;

-- G06 - Qual a proporcao de tentativas recusadas por forma de pagamento?
-- Atende: P1; KPI07 (recusas/tentativas). Estornado continua sendo uma tentativa historica.
SELECT pg.forma_pagamento,COUNT(*) AS tentativas,SUM(pg.status_pagamento='R') AS recusadas,
       ROUND(100.0*SUM(pg.status_pagamento='R')/COUNT(*),2) AS taxa_recusa
FROM pagamento pg JOIN cupom_fiscal c ON c.id_cupom_fiscal=pg.id_cupom_fiscal
JOIN pedido p ON p.id_pedido=c.id_pedido WHERE p.data_hora>=@inicio AND p.data_hora<@fim
GROUP BY pg.forma_pagamento ORDER BY pg.forma_pagamento;

-- G07 - Quais clientes cadastrados repetiram compras e quais nao compraram?
-- Atende: P1; KPI08 (clientes com recompra), apoio ao relacionamento.
WITH compras AS (
 SELECT cl.id_cliente,cl.nome,COUNT(s.id_pedido) AS compras_quitadas
 FROM cliente cl LEFT JOIN vw_situacao_pedido s ON s.id_cliente=cl.id_cliente
  AND s.situacao_financeira='QUITADO' AND s.data_hora>=@inicio AND s.data_hora<@fim
 GROUP BY cl.id_cliente,cl.nome
)
SELECT id_cliente,nome,compras_quitadas,(compras_quitadas>=2) AS cliente_recorrente,
       SUM(compras_quitadas>=2) OVER() AS clientes_recorrentes_total
FROM compras ORDER BY compras_quitadas DESC,id_cliente;

-- G08 - Quais produtos estao abaixo do estoque minimo agora?
-- Atende: P2; KPI09 (quantidade de produtos abaixo do minimo).
SELECT id_produto,nome,quantidade_disponivel,estoque_minimo,
       estoque_minimo-quantidade_disponivel AS unidades_ate_minimo,COUNT(*) OVER() AS produtos_abaixo_minimo
FROM produto WHERE quantidade_disponivel<estoque_minimo ORDER BY unidades_ate_minimo DESC,id_produto;

-- G09 - Quantas unidades foram recebidas por fornecedor e produto no periodo?
-- Atende: P2; KPI10 (unidades recebidas por fornecedor).
SELECT f.id_fornecedor,f.cnpj,pr.id_produto,pr.nome,SUM(ep.quantidade_recebida) AS unidades_recebidas
FROM entrada_estoque e JOIN fornecedor f ON f.id_fornecedor=e.id_fornecedor
JOIN entrada_produto ep ON ep.id_entrada_estoque=e.id_entrada_estoque JOIN produto pr ON pr.id_produto=ep.id_produto
WHERE e.data_hora>= '2026-06-01' AND e.data_hora<@fim
GROUP BY f.id_fornecedor,f.cnpj,pr.id_produto,pr.nome ORDER BY f.id_fornecedor,pr.id_produto;

-- 8. Auditorias. Resultado vazio indica ausencia da inconsistencia especifica.
-- A01 - Existe pedido sem produto? Verifica: RN05.
SELECT p.id_pedido FROM pedido p LEFT JOIN pedido_produto pp ON pp.id_pedido=p.id_pedido GROUP BY p.id_pedido HAVING COUNT(pp.id_produto)=0;
-- A02 - Existe pedido sem cupom fiscal? Verifica: RN10.
SELECT p.id_pedido FROM pedido p LEFT JOIN cupom_fiscal c ON c.id_pedido=p.id_pedido WHERE c.id_cupom_fiscal IS NULL;
-- A03 - Existe cupom sem tentativa de pagamento? Verifica: RN11.
SELECT c.id_cupom_fiscal FROM cupom_fiscal c LEFT JOIN pagamento pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal GROUP BY c.id_cupom_fiscal HAVING COUNT(pg.id_pagamento)=0;
-- A04 - Existe valor aprovado superior ao total? Verifica: RN15.
-- A massa inclui intencionalmente UMA divergencia de R$0,01 para demonstrar deteccao.
SELECT id_pedido,valor_total,valor_pago FROM vw_situacao_pedido WHERE situacao_financeira='DIVERGENCIA';
-- A05 - Existe pedido em preparo, pronto ou entregue sem quitacao? Verifica: RN15/RN17.
SELECT id_pedido,status_preparo,situacao_financeira FROM vw_situacao_pedido WHERE status_preparo IN ('EM_PREPARO','PRONTO','ENTREGUE') AND situacao_financeira<>'QUITADO';
-- A06 - Existe equipamento incompativel com a origem ou balcao sem funcionario? Verifica: RN07/RN08.
SELECT id_pedido FROM pedido WHERE (origem_pedido='T' AND (totem IS NULL OR TRIM(totem)='')) OR (origem_pedido<>'T' AND totem IS NOT NULL) OR (origem_pedido='B' AND id_funcionario IS NULL);
-- A07 - Existe cronologia financeira anterior ao pedido ou cupom? Verifica: RN21.
SELECT pg.id_pagamento FROM pagamento pg JOIN cupom_fiscal c ON c.id_cupom_fiscal=pg.id_cupom_fiscal JOIN pedido p ON p.id_pedido=c.id_pedido
WHERE c.data_hora_emissao<p.data_hora OR pg.data_hora_pagamento<c.data_hora_emissao;
-- A08 - O saldo materializado difere dos recebimentos menos baixas e devolucoes? Verifica: RN24-RN27.
SELECT pr.id_produto,pr.quantidade_disponivel,COALESCE(e.recebido,0)-COALESCE(b.consumido,0) AS saldo_recalculado
FROM produto pr
LEFT JOIN (SELECT id_produto,SUM(quantidade_recebida) AS recebido FROM entrada_produto GROUP BY id_produto) e ON e.id_produto=pr.id_produto
LEFT JOIN (SELECT pp.id_produto,SUM(pp.quantidade-pp.quantidade_devolvida) AS consumido FROM pedido_produto pp JOIN pedido p ON p.id_pedido=pp.id_pedido WHERE p.baixa_estoque_realizada=TRUE GROUP BY pp.id_produto) b ON b.id_produto=pr.id_produto
WHERE pr.quantidade_disponivel<>COALESCE(e.recebido,0)-COALESCE(b.consumido,0);
-- A09 - Existe pedido quitado sem baixa? Verifica: RN26.
SELECT p.id_pedido FROM pedido p JOIN vw_situacao_pedido s ON s.id_pedido=p.id_pedido WHERE s.situacao_financeira='QUITADO' AND NOT p.baixa_estoque_realizada;
-- A10 - Existe devolucao fisica sem baixa ou sem cancelamento? Verifica: RN27.
SELECT pp.id_pedido,pp.id_produto FROM pedido_produto pp JOIN pedido p ON p.id_pedido=pp.id_pedido WHERE pp.quantidade_devolvida>0 AND (NOT p.baixa_estoque_realizada OR p.status_preparo<>'CANCELADO');
-- A11 - Existe recebimento sem produto? Verifica: RN24.
SELECT e.id_entrada_estoque FROM entrada_estoque e LEFT JOIN entrada_produto ep ON ep.id_entrada_estoque=e.id_entrada_estoque GROUP BY e.id_entrada_estoque HAVING COUNT(ep.id_produto)=0;
