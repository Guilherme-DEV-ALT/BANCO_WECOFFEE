"""Gera as versões PDF, PNG e JPG do DER conceitual.

Dependências: python -m pip install reportlab pymupdf==1.26.7
Execução, a partir de qualquer pasta: python caminho/para/gerar_der.py
"""

from pathlib import Path

import pymupdf
from reportlab.lib.colors import HexColor
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[2]
WIDTH, HEIGHT = 1800, 1080
INK = "#172033"
LINE = "#536176"
MUTED = "#61728D"


def generate():
    regular, bold = "Helvetica", "Helvetica-Bold"
    fonts = Path("C:/Windows/Fonts")
    if (fonts / "arial.ttf").exists() and (fonts / "arialbd.ttf").exists():
        pdfmetrics.registerFont(TTFont("Arial", str(fonts / "arial.ttf")))
        pdfmetrics.registerFont(TTFont("Arial-Bold", str(fonts / "arialbd.ttf")))
        regular, bold = "Arial", "Arial-Bold"

    pdf_path = ROOT / "WeCoffee_BRModelo.pdf"
    page = canvas.Canvas(str(pdf_path), pagesize=(WIDTH, HEIGHT))
    page.setTitle("Modelo Conceitual - We Coffee")
    page.setAuthor("We Coffee - Projeto de Banco de Dados")

    def label(text, x, y, size=16, strong=False, color=INK, center=True):
        page.setFillColor(HexColor(color))
        page.setFont(bold if strong else regular, size)
        draw = page.drawCentredString if center else page.drawString
        draw(x, HEIGHT - y, text)

    def connector(*points):
        page.setStrokeColor(HexColor(LINE))
        page.setLineWidth(2)
        path = page.beginPath()
        path.moveTo(points[0][0], HEIGHT - points[0][1])
        for x, y in points[1:]:
            path.lineTo(x, HEIGHT - y)
        page.drawPath(path)

    def entity(name, x, y, width=180, height=80):
        page.setFillColor(HexColor("#FFFFFF"))
        page.setStrokeColor(HexColor(INK))
        page.setLineWidth(2)
        page.roundRect(x, HEIGHT - y - height, width, height, 2, fill=1, stroke=1)
        label(name, x + width / 2, y + height / 2 + 7, 20, strong=True)

    def relation(name, x, y, width=140, height=80):
        page.setFillColor(HexColor("#FFFFFF"))
        page.setStrokeColor(HexColor(INK))
        page.setLineWidth(2)
        path = page.beginPath()
        for i, (px, py) in enumerate(
            [(x - width / 2, y), (x, y - height / 2),
             (x + width / 2, y), (x, y + height / 2)]
        ):
            if i == 0:
                path.moveTo(px, HEIGHT - py)
            else:
                path.lineTo(px, HEIGHT - py)
        path.close()
        page.drawPath(path, fill=1, stroke=1)
        label(name, x, y + 5, 16)

    def cardinality(text, x, y):
        label(text, x, y, 16, color=LINE)

    def attribute(name, x, y, width=170, height=50):
        page.setFillColor(HexColor("#FFFFFF"))
        page.setStrokeColor(HexColor(LINE))
        page.setLineWidth(1.5)
        page.ellipse(x - width / 2, HEIGHT - y - height / 2,
                     x + width / 2, HEIGHT - y + height / 2, fill=1, stroke=1)
        label(name, x, y + 5, 16)

    label("Modelo Conceitual - We Coffee", 900, 48, 30, strong=True)
    label("Notação Entidade-Relacionamento no estilo BRModelo", 900, 78, 17, color=LINE)
    label("VENDAS E ATENDIMENTO", 50, 125, 16, strong=True, color=MUTED, center=False)
    label("ESTOQUE E FORNECIMENTO", 1040, 125, 16, strong=True, color=MUTED, center=False)

    # Cliente, funcionário e totem se relacionam com o pedido conforme o canal.
    connector((220, 210), (270, 210))
    connector((410, 210), (540, 420))
    relation("Realiza", 340, 210)
    connector((220, 440), (540, 440))
    relation("Registra", 340, 440)
    connector((220, 670), (270, 670))
    connector((410, 670), (540, 460))
    relation("Registra", 340, 670)
    cardinality("(0,N)", 245, 195)
    cardinality("(0,1)", 485, 310)
    cardinality("(0,N)", 245, 425)
    cardinality("(0,1)", 480, 425)
    cardinality("(0,N)", 245, 655)
    cardinality("(0,1)", 485, 575)

    # Relações diretas de produtos com pedidos e recebimentos.
    connector((720, 440), (1040, 440))
    relation("Contém", 880, 440)
    cardinality("(1,N)", 765, 425)
    cardinality("(0,N)", 995, 425)

    connector((630, 480), (630, 800))
    relation("Possui", 630, 640)
    cardinality("(1,N)", 665, 560)
    cardinality("(1,1)", 665, 750)

    connector((1230, 190), (1500, 190))
    relation("Fornece", 1365, 190)
    cardinality("(0,N)", 1265, 175)
    cardinality("(1,1)", 1465, 175)

    connector((1500, 230), (1420, 310))
    connector((1280, 310), (1170, 400))
    relation("Contém", 1350, 310)
    cardinality("(1,N)", 1480, 285)
    cardinality("(0,N)", 1200, 350)

    # A disponibilidade e a última atualização pertencem ao próprio produto.
    connector((1230, 440), (1360, 440))
    attribute("quantidade_disponivel", 1500, 440, width=280)
    connector((1230, 460), (1380, 560))
    attribute("data_atualizacao", 1500, 560, width=240)

    # Atributos dos relacionamentos: quantidade vendida, preço da venda e recebimento.
    connector((880, 480), (820, 540))
    connector((880, 480), (970, 610))
    attribute("quantidade", 820, 565)
    attribute("preco_unitario", 970, 635, width=190)
    connector((1420, 310), (1515, 310))
    attribute("quantidade", 1600, 310)

    entity("CLIENTE", 50, 170, 170)
    entity("FUNCIONARIO", 30, 400, 190)
    entity("TOTEM", 50, 630, 170)
    entity("PEDIDO", 540, 400)
    entity("PAGAMENTO", 540, 800)
    entity("PRODUTO", 1040, 400, 190)
    entity("FORNECEDOR", 1040, 150, 190)
    entity("ENTRADA_ESTOQUE", 1500, 150, 240)

    page.setFillColor(HexColor("#F7F9FC"))
    page.setStrokeColor(HexColor("#CCD7E6"))
    page.setLineWidth(1.5)
    page.roundRect(50, 35, 1690, 110, 8, fill=1, stroke=1)
    label("Leitura das cardinalidades: (mínimo, máximo).", 75, 965, 16,
          strong=True, center=False, color=LINE)
    label("Cada pedido contém um ou mais produtos e possui um ou mais pagamentos.",
          75, 993, 16, center=False, color=LINE)
    label("PEDIDO e ENTRADA_ESTOQUE se relacionam diretamente com PRODUTO (N:M).",
          75, 1021, 16, center=False, color=LINE)
    page.showPage()
    page.save()

    with pymupdf.open(pdf_path) as document:
        image = document[0].get_pixmap(dpi=72, alpha=False)
        image.save(str(ROOT / "WECOFFE/Modelo_Conceitual_WeCoffee_BRModelo.png"))
        image.save(str(ROOT / "WECOFFE/modelagem/Modelo_Conceitual_WeCoffee_BRModelo.jpg"),
                   jpg_quality=95)


if __name__ == "__main__":
    generate()
