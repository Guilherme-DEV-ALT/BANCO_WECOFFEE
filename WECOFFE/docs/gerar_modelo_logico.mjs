// Gera SVG na notação visual do modelo lógico brModelo a partir dos DDLs.
// Executar: node docs/gerar_modelo_logico.mjs
import fs from 'node:fs/promises';
const dir = new URL('../WECOFFE/modelagem/', import.meta.url);
const ddl = (await fs.readFile(new URL('esquema_logico.sql',dir),'utf8')) + '\n'
  + (await fs.readFile(new URL('estoque_logico.sql',dir),'utf8'));
const tables={};
for(const m of ddl.matchAll(/CREATE TABLE (\w+) \(([\s\S]*?)\) ENGINE=InnoDB;/g)){
  const rows=[];
  for(const line of m[2].split('\n')){
    const col=line.match(/^\s*(\w+) (INT|VARCHAR\(\d+\)|DECIMAL\(\d+,\d+\)|DATETIME)(?=\s)/);
    if(col) rows.push([col[1],col[2],line.includes('PRIMARY KEY')?'PK':'']);
  }
  for(const row of rows){
    const pk=m[2].match(/PRIMARY KEY \(([^)]+)\)/);
    if(pk?.[1].split(',').map(s=>s.trim()).includes(row[0])) row[2]='PK';
    if([...m[2].matchAll(/FOREIGN KEY \(([^)]+)\)/g)].some(f=>f[1].split(',').map(s=>s.trim()).includes(row[0])))
      row[2]+=(row[2]?', ':'')+'FK';
  }
  tables[m[1]]=rows;
}
const positions=[['CLIENTE',40,100],['FUNCIONARIO',560,100],['PEDIDO',40,400],
 ['CUPOM_FISCAL',560,400],['PAGAMENTO',1080,400],['ITEM_PEDIDO',560,900],
 ['PRODUTO',1080,900],['ESTOQUE',1600,900],['MOVIMENTACAO_ESTOQUE',1600,100]];
const out=['<svg xmlns="http://www.w3.org/2000/svg" width="2110" height="1220" viewBox="0 0 2110 1220">',
 '<rect width="2110" height="1220" fill="white"/>',
 '<style>text{font-family:Arial,sans-serif;fill:#111;font-size:17px}.title{font-weight:bold;font-size:20px}.card{font-size:18px}</style>',
 '<text x="40" y="32" class="title">We Coffee — Modelo lógico relacional · Estoque incluído apenas nesta camada</text>'];
function link(path,labels){
 out.push(`<path d="${path}" stroke="#222" stroke-width="2" fill="none"/>`);
 for(const [x,y,s]of labels)out.push(`<text x="${x}" y="${y}" class="card">${s}</text>`);
}
link('M 200 244 V 400',[[210,270,'(0, 1)'],[210,380,'(0, n)']]);
link('M 785 244 V 310 H 390 V 400',[[795,270,'(0, 1)'],[400,380,'(0, n)']]);
link('M 490 470 H 560',[[495,453,'(1, 1)'],[495,500,'(1, 1)']]);
link('M 1010 470 H 1080',[[1015,453,'(1, 1)'],[1015,500,'(1, n)']]);
link('M 240 714 V 810 H 650 V 900',[[250,745,'(1, 1)'],[660,880,'(1, n)']]);
link('M 1010 970 H 1080',[[1015,954,'(0, n)'],[1015,999,'(1, 1)']]);
link('M 1530 970 H 1600',[[1535,954,'(1, 1)'],[1535,999,'(1, 1)']]);
link('M 1825 448 V 900',[[1835,480,'(0, n)'],[1835,880,'(1, 1)']]);
link('M 1010 150 H 1600',[[1020,135,'(1, 1)'],[1520,135,'(0, n)']]);
link('M 950 900 V 760 H 1560 V 330 H 1600',[[865,880,'(0, 1)'],[1485,315,'(0, n)']]);
for(const [name,x,y] of positions){
 const rows=tables[name];
 if(!rows?.length)throw new Error(`Tabela sem colunas: ${name}`);
 out.push(`<rect x="${x}" y="${y}" width="450" height="${42+rows.length*34}" fill="white" stroke="#111" stroke-width="2"/>`,
  `<path d="M ${x} ${y+42} H ${x+450}" stroke="#111"/>`,
  `<text x="${x+12}" y="${y+28}" class="title">${name}</text>`);
 for(const [index,[col,type,key]]of rows.entries())out.push(
  `<text x="${x+12}" y="${y+66+index*34}">${col}</text>`,
  `<text x="${x+235}" y="${y+66+index*34}">${type}</text>`,
  `<text x="${x+377}" y="${y+66+index*34}">${key}</text>`);
}
out.push('<text x="40" y="1140">Cardinalidade junto à tabela: quantidade de suas linhas para uma linha da tabela oposta. Ligação ITEM_PEDIDO–MOVIMENTACAO_ESTOQUE: FK composta.</text>',
 '<text x="40" y="1175">PK = chave primária · FK = chave estrangeira · NOT NULL, UNIQUE, CHECK e DEFAULT: dicionário lógico e script SQL.</text></svg>');
await fs.writeFile(new URL('Modelo_Logico_WeCoffee.svg',dir),out.join('\n'));
console.log('SVG gerado: 9 tabelas, '+Object.values(tables).reduce((n,r)=>n+r.length,0)+' colunas.');
