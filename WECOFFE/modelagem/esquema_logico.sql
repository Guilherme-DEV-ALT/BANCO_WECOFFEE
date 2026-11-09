-- Levantamento: entrevista com o auxiliar geral em 08/11/2026, relatada em 09/11/2026.
-- RN33: fechamento ao final de cada dia, exclusivamente por gerentes (confirmado).
-- RN23/RN24: cancelamento da nota/pedido e estorno imediato pelo cartão,
-- com balanceamento automático no sistema existente (confirmados pelo relato).
-- Este SQL não executa integrações fiscais/de cartão nem registra fechamentos.
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
-- RN22: validar quitação sob controle de concorrência antes de liberar preparo.
-- RN23/RN24: validar transições e confirmação externa da devolução.
-- Essas regras exigem serviço transacional/rotinas controladas ainda pendentes.
