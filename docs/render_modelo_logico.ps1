param([string]$ModelDir=(Join-Path $PSScriptRoot '../WECOFFE/modelagem'))
# Exporta o subconjunto SVG usado pelo gerador para PNG no Windows (.NET).
Add-Type -AssemblyName System.Drawing
[xml]$diagram=Get-Content -Raw -Encoding UTF8 (Join-Path $ModelDir 'Modelo_Logico_WeCoffee.svg')
$bitmap=New-Object System.Drawing.Bitmap ([int]$diagram.svg.width),([int]$diagram.svg.height)
$graphics=[Drawing.Graphics]::FromImage($bitmap)
$graphics.Clear([Drawing.Color]::White)
$graphics.SmoothingMode='AntiAlias'
$graphics.TextRenderingHint='AntiAliasGridFit'
$pen=New-Object Drawing.Pen ([Drawing.Color]::Black),2
foreach($element in $diagram.DocumentElement.ChildNodes){
 if($element.LocalName -eq 'rect'){
  $graphics.FillRectangle([Drawing.Brushes]::White,[int]$element.x,[int]$element.y,[int]$element.width,[int]$element.height)
  $graphics.DrawRectangle($pen,[int]$element.x,[int]$element.y,[int]$element.width,[int]$element.height)
 }
 if($element.LocalName -eq 'path'){
  $tokens=[regex]::Matches($element.d,'[MHV]|[0-9]+') | ForEach-Object {$_.Value}
  $idx=0;$px=0;$py=0
  while($idx -lt $tokens.Count){
   $op=$tokens[$idx];$idx++
   if($op -eq 'M'){$px=[int]$tokens[$idx];$py=[int]$tokens[$idx+1];$idx+=2}
   elseif($op -eq 'H'){$nx=[int]$tokens[$idx];$idx++;$graphics.DrawLine($pen,$px,$py,$nx,$py);$px=$nx}
   elseif($op -eq 'V'){$ny=[int]$tokens[$idx];$idx++;$graphics.DrawLine($pen,$px,$py,$px,$ny);$py=$ny}
  }
 }
 if($element.LocalName -eq 'text'){
  $size=17;$style=[Drawing.FontStyle]::Regular
  if($element.class -eq 'title'){$size=20;$style=[Drawing.FontStyle]::Bold}
  if($element.class -eq 'card'){$size=18}
  $font=New-Object Drawing.Font 'Arial',$size,$style,([Drawing.GraphicsUnit]::Pixel)
  $graphics.DrawString($element.InnerText,$font,[Drawing.Brushes]::Black,[single]$element.x,([single]$element.y-$size))
  $font.Dispose()
 }
}
$bitmap.Save((Join-Path (Resolve-Path $ModelDir) 'Modelo_Logico_WeCoffee.png'),[Drawing.Imaging.ImageFormat]::Png)
$pen.Dispose();$graphics.Dispose();$bitmap.Dispose()
