param(
    [string]$Mysql = 'C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe',
    [int]$Port = 13367,
    [string]$DocsDir = $PSScriptRoot
)
# Executar apenas na instância temporária de validação, após docs/script.sql.
# Conexão local sem senha; não utiliza nem altera a instância habitual da máquina.
$ErrorActionPreference = 'Stop'
$clientArgs = @('--no-defaults', '--protocol=TCP', '--host=127.0.0.1', "--port=$Port",
    '--user=root', '--default-character-set=utf8mb4', '--batch', '--raw',
    '--skip-column-names', '--database=wecoffee_academico')
$scriptText = Get-Content -LiteralPath (Join-Path $DocsDir 'script.sql') -Raw -Encoding UTF8
$report = [Collections.Generic.List[string]]::new()
function Query([string]$Sql) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output = & $Mysql @clientArgs "--execute=$Sql" 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $previous
    return @{ Code = $code; Text = ($output | Out-String).Trim() }
}
function Assert-Query([string]$Name, [string]$Sql, [string]$Expected) {
    $result = Query $Sql
    if ($result.Code -ne 0 -or $result.Text -ne $Expected) {
        throw "$Name falhou: esperado [$Expected], obtido [$($result.Text)]"
    }
    $report.Add("PASS: $Name")
}
function Audit([string]$Code) {
    $pattern = '(?ms)^-- ' + $Code + ' — .*?(?=^-- A\d{2} — |\z)'
    $match = [regex]::Match($scriptText, $pattern)
    if (-not $match.Success) { throw "Auditoria ausente: $Code" }
    return $match.Value
}
Assert-Query 'Contagens finais (20 clientes, 8 funcionários, 13 produtos, 60 pedidos, 120 itens, 60 cupons, 72 pagamentos)' `
    "SELECT CONCAT_WS(',',(SELECT COUNT(*) FROM CLIENTE),(SELECT COUNT(*) FROM FUNCIONARIO),(SELECT COUNT(*) FROM PRODUTO),(SELECT COUNT(*) FROM PEDIDO),(SELECT COUNT(*) FROM ITEM_PEDIDO),(SELECT COUNT(*) FROM CUPOM_FISCAL),(SELECT COUNT(*) FROM PAGAMENTO));" '20,8,13,60,120,60,72'
Assert-Query 'Vendas quitadas nos dois meses: 39 pedidos, total 2075, ticket médio 53.21' @'
WITH i AS (SELECT id_pedido,SUM(quantidade*preco_unitario) total FROM ITEM_PEDIDO GROUP BY id_pedido),
pg AS (SELECT id_cupom_fiscal,SUM(CASE WHEN status_pagamento='Aprovado' THEN valor_pagamento ELSE 0 END) pago FROM PAGAMENTO GROUP BY id_cupom_fiscal)
SELECT CONCAT_WS(',',COUNT(*),SUM(i.total),CAST(AVG(i.total) AS DECIMAL(12,2)))
FROM PEDIDO p JOIN i ON i.id_pedido=p.id_pedido JOIN CUPOM_FISCAL c ON c.id_pedido=p.id_pedido
JOIN pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal WHERE p.status_preparo<>'CANCELADO' AND i.total=pg.pago;
'@ '39,2075.00,53.21'
foreach ($code in @('A01','A02','A03','A04','A06','A07','A08','A09','A10','A12','A13','A14','A15','A16')) {
    Assert-Query "$code sem exceções na carga" (Audit $code) ''
}
Assert-Query 'A05 encontra devolução pendente de 48 no pedido 9' (Audit 'A05') "9`t48.00"
Assert-Query 'A11 encontra excesso de 5 no pedido 7' (Audit 'A11') "7`t28.00`t33.00`t5.00"

# Injeções transacionais: comprovam que auditorias encontram falhas não bloqueadas por FK.
Assert-Query 'A01 detecta pedido sem item' ("START TRANSACTION; INSERT INTO PEDIDO(id_pedido,origem_pedido) VALUES(999,'DELIVERY');`n" + (Audit 'A01') + "`nROLLBACK;") '999'
Assert-Query 'A02 detecta pedido sem cupom' ("START TRANSACTION; INSERT INTO PEDIDO(id_pedido,origem_pedido) VALUES(999,'DELIVERY');`n" + (Audit 'A02') + "`nROLLBACK;") "999`t0"
Assert-Query 'A03 detecta cupom sem tentativa' ("START TRANSACTION; INSERT INTO PEDIDO(id_pedido,origem_pedido) VALUES(999,'DELIVERY'); INSERT INTO CUPOM_FISCAL(id_cupom_fiscal,id_pedido,numero) VALUES(999,999,'TEST-999');`n" + (Audit 'A03') + "`nROLLBACK;") '999'
Assert-Query 'A04 detecta entregue sem quitação' ("START TRANSACTION; UPDATE PAGAMENTO SET valor_pagamento=1 WHERE id_cupom_fiscal=1;`n" + (Audit 'A04') + "`nROLLBACK;") "1`t46.00`t1.00"
# Alteração de item com baixa passa a ser bloqueada pelo trigger (teste abaixo).

$rejections = @(
    @('Imutabilidade do item após baixa', "UPDATE ITEM_PEDIDO SET preco_unitario=99 WHERE id_pedido=1 AND id_produto=1", '1644'),
    @('PK composta', "INSERT INTO ITEM_PEDIDO VALUES(5,5,1,12)", '1062'),
    @('FK de produto', "INSERT INTO ITEM_PEDIDO VALUES(5,999,1,10)", '1452'),
    @('Quantidade positiva', "UPDATE ITEM_PEDIDO SET quantidade=0 WHERE id_pedido=5", '3819'),
    @('Totem obrigatório', "INSERT INTO PEDIDO(origem_pedido) VALUES('TOTEM')", '3819'),
    @('Domínio do status', "UPDATE PEDIDO SET status_preparo='INVALIDO' WHERE id_pedido=1", '1644'),
    @('Valor de pagamento positivo', "UPDATE PAGAMENTO SET valor_pagamento=0 WHERE id_pagamento=1", '3819'),
    @('Número fiscal único', "UPDATE CUPOM_FISCAL SET numero='SIM-2026-0001' WHERE id_pedido=2", '1062'),
    @('Nome obrigatório', "INSERT INTO CLIENTE(nome) VALUES(NULL)", '1048'),
    @('Documento único', "INSERT INTO CLIENTE(nome,cpf_cnpj) VALUES('Teste 1','00000000000'),('Teste 2','00000000000')", '1062'),
    @('Exclusão de pedido referenciado', "DELETE FROM PEDIDO WHERE id_pedido=1", '1451')
)
foreach ($case in $rejections) {
    $result = Query ("START TRANSACTION; " + $case[1] + "; ROLLBACK;")
    if ($result.Code -eq 0 -or $result.Text -notmatch ('ERROR ' + $case[2])) {
        throw "Restrição $($case[0]) não rejeitou como esperado: $($result.Text)"
    }
    $report.Add("PASS: rejeição de $($case[0]) (MySQL $($case[2]))")
}
Assert-Query 'Rollback preservou os 60 pedidos' 'SELECT COUNT(*) FROM PEDIDO;' '60'
# Verificações específicas da extensão de estoque.
Assert-Query 'Estoque: 13 saldos e 103 movimentos' "SELECT CONCAT_WS(',',(SELECT COUNT(*) FROM ESTOQUE),(SELECT COUNT(*) FROM MOVIMENTACAO_ESTOQUE));" '13,103'
Assert-Query 'Produto 7 sem saldo; produto 6 abaixo do mínimo' "SELECT CONCAT_WS(',',id_produto,quantidade_disponivel,estoque_minimo) FROM ESTOQUE WHERE id_produto IN(6,7) ORDER BY id_produto;" ("6,3,5" + [Environment]::NewLine + "7,0,5")
Assert-Query 'Cancelamento antes da baixa não movimenta estoque' "SELECT COUNT(*) FROM MOVIMENTACAO_ESTOQUE WHERE id_pedido=9;" '0'
Assert-Query 'Retorno confirmado repõe somente o produto 1 do pedido 8' "SELECT CONCAT_WS(',',id_produto,quantidade) FROM MOVIMENTACAO_ESTOQUE WHERE id_pedido=8 AND tipo='RETORNO';" '1,1'
Assert-Query 'A12 detecta saldo alterado fora do livro' ("START TRANSACTION; UPDATE ESTOQUE SET quantidade_disponivel=quantidade_disponivel+1 WHERE id_produto=1;
"+(Audit 'A12')+"
ROLLBACK;") "1	47	46"
Assert-Query 'A15 detecta produto sem estoque' ("START TRANSACTION; INSERT INTO PRODUTO(id_produto,nome,preco) VALUES(900,'Teste sem estoque',1); DELETE FROM ESTOQUE WHERE id_produto=900;
"+(Audit 'A15')+"
ROLLBACK;") '900'
$stockRejections=@(
 @('Pedido novo já em preparo',"INSERT INTO PEDIDO(origem_pedido,status_preparo) VALUES('DELIVERY','EM_PREPARO')",'1644'),
 @('Responsável inexistente',"CALL sp_registrar_movimentacao(1,'ENTRADA',1,999,'Teste','TEST:ATOR')",'1452'),
 @('Baixa duplicada',"CALL sp_liberar_preparo(1,5)",'1644'),
 @('Baixa sem quitação',"CALL sp_liberar_preparo(5,5)",'1644'),
 @('Baixa de cancelado',"CALL sp_liberar_preparo(9,5)",'1644'),
 @('Saída sem saldo',"CALL sp_registrar_movimentacao(7,'PERDA',1,5,'Teste','TEST:SEM_SALDO')",'1644'),
 @('Retorno sem aptidão',"CALL sp_retornar_estoque(8,2,5,FALSE,'Teste','TEST:INAPTO')",'1644'),
 @('Retorno sem baixa',"CALL sp_retornar_estoque(9,2,5,TRUE,'Teste','TEST:SEM_BAIXA')",'1644'),
 @('Retorno duplicado',"CALL sp_retornar_estoque(8,1,5,TRUE,'Teste','TEST:DUPLICADO')",'1062'),
 @('Edição de movimento',"UPDATE MOVIMENTACAO_ESTOQUE SET quantidade=99 WHERE id_movimentacao=1",'1644'),
 @('Exclusão de movimento',"DELETE FROM MOVIMENTACAO_ESTOQUE WHERE id_movimentacao=1",'1644'),
 @('Preparo sem baixa',"UPDATE PEDIDO SET status_preparo='EM_PREPARO' WHERE id_pedido=5",'1644')
)
foreach($case in $stockRejections){
 $result=Query ("START TRANSACTION; "+$case[1]+"; ROLLBACK;")
 if($result.Code -eq 0 -or $result.Text -notmatch ('ERROR '+$case[2])){throw "Estoque: $($case[0]) falhou: $($result.Text)"}
 $report.Add("PASS: estoque rejeita $($case[0])")
}
Assert-Query 'Falhas de estoque não deixaram saldo ou movimentos parciais' (Audit 'A12') ''
Assert-Query 'Falhas preservaram 103 movimentos' 'SELECT COUNT(*) FROM MOVIMENTACAO_ESTOQUE;' '103'
# Cobertura de cenários exigidos para a massa de dados.
Assert-Query 'Pedidos abrangem setembro e outubro' "SELECT GROUP_CONCAT(DISTINCT DATE_FORMAT(data_hora,'%Y-%m') ORDER BY DATE_FORMAT(data_hora,'%Y-%m')) FROM PEDIDO;" '2026-09,2026-10'
Assert-Query 'Clientes 19 e 20 permanecem sem compras e sem pedidos' "SELECT GROUP_CONCAT(c.id_cliente ORDER BY c.id_cliente) FROM CLIENTE c WHERE NOT EXISTS(SELECT 1 FROM PEDIDO p WHERE p.id_cliente=c.id_cliente);" '19,20'
Assert-Query 'Todos os canais têm vinte pedidos na amostra' "SELECT GROUP_CONCAT(CONCAT(origem_pedido,':',n) ORDER BY origem_pedido) FROM (SELECT origem_pedido,COUNT(*) n FROM PEDIDO GROUP BY origem_pedido) x;" 'BALCÃO:20,DELIVERY:20,TOTEM:20'
Assert-Query 'Quatro formas de pagamento e três situações' "SELECT CONCAT_WS(',',COUNT(DISTINCT forma_pagamento),COUNT(DISTINCT status_pagamento)) FROM PAGAMENTO;" '4,3'
Assert-Query 'Sete pedidos cancelados entre os cenários de teste' "SELECT COUNT(*) FROM PEDIDO WHERE status_preparo='CANCELADO';" '7'
Assert-Query 'Itens variam entre uma e três linhas por pedido' "SELECT CONCAT_WS(',',MIN(n),MAX(n)) FROM (SELECT id_pedido,COUNT(*) n FROM ITEM_PEDIDO GROUP BY id_pedido) x;" '1,3'
Assert-Query 'G01: outubro tem 30 vendas quitadas de 1574 reais' @'
WITH i AS (SELECT id_pedido,SUM(quantidade*preco_unitario) total FROM ITEM_PEDIDO GROUP BY id_pedido),
pg AS (SELECT id_cupom_fiscal,SUM(CASE WHEN status_pagamento='Aprovado' THEN valor_pagamento ELSE 0 END) pago FROM PAGAMENTO GROUP BY id_cupom_fiscal)
SELECT CONCAT_WS(',',COUNT(*),SUM(i.total)) FROM PEDIDO p JOIN i ON i.id_pedido=p.id_pedido
JOIN CUPOM_FISCAL c ON c.id_pedido=p.id_pedido JOIN pg ON pg.id_cupom_fiscal=c.id_cupom_fiscal
WHERE p.data_hora>='2026-10-01' AND p.data_hora<'2026-11-01' AND p.status_preparo<>'CANCELADO' AND i.total=pg.pago;
'@ '30,1574.00'
$report | Set-Content -LiteralPath (Join-Path $DocsDir 'resultado_validacao_mysql.txt') -Encoding UTF8
$report
