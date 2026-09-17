import csv

unique_colors = set()
with open('colores_a_traducir_corregido.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        c1 = row.get('Color__c', '').strip()
        c2 = row.get('Color2__c', '').strip()
        if c1: unique_colors.add(c1)
        if c2: unique_colors.add(c2)

for c in sorted(list(unique_colors)):
    print(c)
