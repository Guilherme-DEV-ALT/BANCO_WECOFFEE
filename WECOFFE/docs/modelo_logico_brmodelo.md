# Modelo lógico editável no brModelo

O arquivo [Modelo_Logico_WeCoffee.brM3](../modelagem/Modelo_Logico_WeCoffee.brM3) é um **diagrama lógico nativo do brModelo 3**, com tabelas, campos, restrições e ligações editáveis. Sua [imagem PNG](../modelagem/Modelo_Logico_WeCoffee_brModelo.png) foi renderizada pelo motor do aplicativo depois da reabertura do `.brM3`.

## Abrir e editar

1. Abrir o brModelo 3.
2. Selecionar **Arquivo → Abrir** e escolher `WECOFFE/modelagem/Modelo_Logico_WeCoffee.brM3`.
3. Ajustar o zoom para consultar o desenho; o arquivo é salvo inicialmente em 50%.
4. Selecionar uma tabela para editar seus campos e sua integridade referencial. O complemento de cada campo guarda NULL/NOT NULL, DEFAULT e AUTO_INCREMENT quando presentes. As observações da tabela guardam seu DDL original, incluindo CHECKs.
5. Salvar as alterações no arquivo lógico. Alterações feitas no desenho não modificam automaticamente o SQL.

## Estrutura representada

| Tabela | Chave primária | Referências |
|---|---|---|
| CLIENTE | id_cliente | — |
| FUNCIONARIO | id_funcionario | — |
| PRODUTO | id_produto | — |
| PEDIDO | id_pedido | CLIENTE e FUNCIONARIO, opcionais |
| ITEM_PEDIDO | (id_pedido, id_produto) | PEDIDO e PRODUTO |
| CUPOM_FISCAL | id_cupom_fiscal | PEDIDO, com id_pedido único |
| PAGAMENTO | id_pagamento | CUPOM_FISCAL |
| ESTOQUE | id_produto | PRODUTO |
| MOVIMENTACAO_ESTOQUE | id_movimentacao | ESTOQUE, FUNCIONARIO e a chave composta de ITEM_PEDIDO |

São **9 tabelas, 44 colunas, 9 PKs, 5 UNIQUEs e 10 FKs**. As UNIQUEs são: CLIENTE.cpf_cnpj; CUPOM_FISCAL.id_pedido; CUPOM_FISCAL.numero; MOVIMENTACAO_ESTOQUE.referencia; e MOVIMENTACAO_ESTOQUE.(id_pedido, id_produto, tipo). O ícone UNIQUE indica participação na restrição, inclusive quando composta.

As cardinalidades são lidas junto à tabela: quantidade de suas linhas para uma linha da tabela oposta. Os mínimos de um item por pedido, um cupom por pedido e uma tentativa por cupom expressam regras de negócio; dependem das rotinas e validações já descritas no README. A FK composta de movimentação é opcional porque id_pedido admite NULL, conforme o tipo do movimento.

`valor_total` continua calculado pela soma de `quantidade × preco_unitario` dos itens, sem coluna armazenada em PEDIDO. Estoque integra a camada lógica/física já aprovada no projeto. O arquivo conceitual existente não foi alterado.

## Atualizar o modelo

Para atualizar o desenho, editar diretamente o arquivo `.brM3` no brModelo, usando `WECOFFE/docs/script.sql` como referência para tabelas, campos e restrições. Se houver mudança de estrutura, manter o arquivo lógico, o SQL e o dicionário de dados alinhados e exportar uma nova imagem pelo aplicativo.

## Validação realizada

O arquivo foi salvo e reaberto pelo motor do brModelo. Foram comparados tabelas, campos, tipos, complementos, flags, restrições, referências e cardinalidades; também foram verificadas dez linhas conectadas e todas as restrições válidas. A conferência pela interface do aplicativo ficou pendente após a interrupção do controle pelo usuário. As imagens SVG/PNG anteriores permanecem como representações auxiliares.
