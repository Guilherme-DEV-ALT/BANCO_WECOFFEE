param(
 [string]$Mysql='C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe',
 [int]$Port=13367,
 [string]$DocsDir=$PSScriptRoot
)
# Apenas na instância descartável de teste, sem banco wecoffee_teste_concorrencia.
$ErrorActionPreference='Stop'
$argsBase=@('--no-defaults','--protocol=TCP','--host=127.0.0.1',"--port=$Port",'--user=root',
 '--default-character-set=utf8mb4','--batch','--raw','--skip-column-names')
$tempSql=Join-Path ([IO.Path]::GetTempPath()) ('wecoffee-concorrencia-'+[guid]::NewGuid().ToString('N')+'.sql')
$copy=[IO.File]::ReadAllText((Join-Path $DocsDir 'script.sql')).Replace('wecoffee_academico','wecoffee_teste_concorrencia')
[IO.File]::WriteAllText($tempSql,$copy,[Text.UTF8Encoding]::new($false))
$sourcePath=$tempSql.Replace('\','/')
try {
 & $Mysql @argsBase "--execute=source $sourcePath" | Out-Null
 if($LASTEXITCODE -ne 0){throw 'Falha ao preparar banco separado de teste'}
} finally {Remove-Item -LiteralPath $tempSql}
$argsBase+='--database=wecoffee_teste_concorrencia'
$report=[Collections.Generic.List[string]]::new()
function Run([string]$Sql){
 $previous=$ErrorActionPreference
 $ErrorActionPreference='Continue'
 $output=& $Mysql @argsBase "--execute=$Sql" 2>&1
 $code=$LASTEXITCODE
 $ErrorActionPreference=$previous
 return @{Code=$code;Text=($output|Out-String).Trim()}
}
function Assert-Sql([string]$Label,[string]$Sql,[string]$Expected){
 $result=Run $Sql
 if($result.Code -ne 0 -or $result.Text -ne $Expected){throw "$Label falhou: $($result.Text)"}
 $report.Add("PASS: $Label")
}
$fixture=@'
START TRANSACTION;
INSERT INTO PEDIDO(id_pedido,origem_pedido) VALUES(900,'DELIVERY');
INSERT INTO ITEM_PEDIDO VALUES(900,1,1,10),(900,7,1,8);
INSERT INTO CUPOM_FISCAL(id_cupom_fiscal,id_pedido,numero) VALUES(900,900,'TEST-900');
INSERT INTO PAGAMENTO(id_pagamento,id_cupom_fiscal,forma_pagamento,valor_pagamento,status_pagamento)
 VALUES(900,900,'PIX',18,'Aprovado');
COMMIT;
'@
$result=Run $fixture
if($result.Code -ne 0){throw $result.Text}
$result=Run 'CALL sp_liberar_preparo(900,5);'
if($result.Code -eq 0 -or $result.Text -notmatch 'saldo insuficiente'){throw 'Baixa parcial deveria falhar por falta do produto 7'}
$report.Add('PASS: pedido com um produto disponível e outro sem saldo foi rejeitado')
Assert-Sql 'Rollback integral preservou saldo, pedido recebido e ausência de baixas' @'
SELECT CONCAT_WS(',',(SELECT quantidade_disponivel FROM ESTOQUE WHERE id_produto=1),
 (SELECT status_preparo FROM PEDIDO WHERE id_pedido=900),
 (SELECT COUNT(*) FROM MOVIMENTACAO_ESTOQUE WHERE id_pedido=900));
'@ '46,RECEBIDO,0'

# Dois clientes independentes disputam as mesmas 46 unidades.
$processes=@()
foreach($ref in @('TEST:CONC:1','TEST:CONC:2')){
 $info=[Diagnostics.ProcessStartInfo]::new()
 $info.FileName=$Mysql
 $info.Arguments=($argsBase -join ' ')+" --execute=`"CALL sp_registrar_movimentacao(1,'PERDA',46,5,'Teste concorrente','$ref');`""
 $info.UseShellExecute=$false
 $info.CreateNoWindow=$true
 $info.RedirectStandardOutput=$true
 $info.RedirectStandardError=$true
 $process=[Diagnostics.Process]::new()
 $process.StartInfo=$info
 [void]$process.Start()
 $processes+=@{Process=$process;Output=$process.StandardOutput.ReadToEndAsync();Error=$process.StandardError.ReadToEndAsync()}
}
$success=0;$rejected=0
foreach($entry in $processes){
 $entry.Process.WaitForExit()
 $message=$entry.Error.Result
 if($entry.Process.ExitCode -eq 0){$success++}
 elseif($message -match 'saldo insuficiente'){$rejected++}
 else{throw "Falha inesperada na concorrência: $message"}
 $entry.Process.Dispose()
}
if($success -ne 1 -or $rejected -ne 1){throw "Esperado um sucesso e uma recusa; obtido $success / $rejected"}
$report.Add('PASS: duas conexões concorrentes produziram um sucesso e uma recusa por saldo')
Assert-Sql 'Concorrência terminou com saldo zero e uma única saída confirmada' @'
SELECT CONCAT_WS(',',(SELECT quantidade_disponivel FROM ESTOQUE WHERE id_produto=1),
 (SELECT COUNT(*) FROM MOVIMENTACAO_ESTOQUE WHERE referencia IN('TEST:CONC:1','TEST:CONC:2')));
'@ '0,1'
$report | Set-Content -LiteralPath (Join-Path $DocsDir 'resultado_concorrencia_mysql.txt') -Encoding UTF8
$report
