import csv
import re

translations = {
    'BLANCO': 'WHITE', 'BLANCA': 'WHITE',
    'NEGRO': 'BLACK', 'NEGRA': 'BLACK',
    'GRIS': 'GREY',
    'MADERA': 'WOOD', 'WOODEN': 'WOOD',
    'MARRON': 'BROWN', 'MARRÓN': 'BROWN', 'CAFE': 'BROWN', 'CAFÉ': 'BROWN',
    'ROJO': 'RED', 'ROJA': 'RED',
    'AZUL': 'BLUE',
    'AMARILLO': 'YELLOW', 'AMARILLA': 'YELLOW',
    'VERDE': 'GREEN',
    'ROSA': 'PINK', 'ROSADO': 'PINK',
    'MORADO': 'PURPLE', 'PURPURA': 'PURPLE', 'PÚRPURA': 'PURPLE',
    'NARANJA': 'ORANGE',
    'ACQUA': 'AQUA', 'TURQUESA': 'TURQUOISE',
    'NATURAL': 'NATURAL',
    'ORO': 'GOLD', 'DORADO': 'GOLD',
    'PLATA': 'SILVER', 'PLATEADO': 'SILVER',
    'BRONCE': 'BRONZE',
    'CLARO': 'LIGHT',
    'OSCURO': 'DARK', 'OBSCURO': 'DARK',
    'TRANSPARENTE': 'TRANSPARENT',
    'VARIOS': 'MULTIPLE', 'VARIOS COLORES': 'MULTIPLE COLORS', 'VARIO': 'MULTIPLE', 'VARIOR': 'MULTIPLE',
    'PIEDRA': 'STONE',
    'MULTICOLOR': 'MULTICOLOR',
    'NOGAL': 'WALNUT', 'NUEZ': 'WALNUT',
    'PINO': 'PINE',
    'ACERO': 'STEEL',
    'METAL': 'METAL',
    'CEMENTO': 'CEMENT',
    'MARMOL': 'MARBLE', 'MÁRMOL': 'MARBLE',
    'LIMA': 'LIME', 'LIMÓN': 'LIME',
    'COJIN': 'CUSHION',
    'NIÑO': 'BOY', 'NIÑA': 'GIRL',
    'Y': 'AND', 'O': 'OR',
    'CLARA': 'LIGHT', 'OSCURA': 'DARK',
    'OBSCURA': 'DARK',
    'ZAFIRO': 'SAPPHIRE',
    'CREMA': 'CREAM',
    'BEIGE': 'BEIGE',
    'SURTIDO COLORES': 'ASSORTED COLORS',
    'MACARRON': 'MACARON',
    'RAYADO': 'STRIPED',
    'IMITACION': 'FAUX', 'IMITACIÓN': 'FAUX'
}

def translate(text):
    if not text: return text
    t = text.upper()
    words = re.split(r'(\W+)', t)
    for i, w in enumerate(words):
        if w in translations:
            words[i] = translations[w]
    return "".join(words)

with open('colores_a_traducir_corregido.csv', 'r', encoding='utf-8-sig') as f_in, \
     open('colores_traducidos_ingles.csv', 'w', newline='', encoding='utf-8-sig') as f_out:
    
    reader = csv.DictReader(f_in)
    fieldnames = reader.fieldnames
    writer = csv.DictWriter(f_out, fieldnames=fieldnames)
    writer.writeheader()
    
    for row in reader:
        row['Color__c'] = translate(row.get('Color__c', '').strip())
        row['Color2__c'] = translate(row.get('Color2__c', '').strip())
        writer.writerow(row)
