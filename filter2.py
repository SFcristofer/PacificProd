import csv

with open('colorESP.csv', 'r', encoding='latin1') as f_in, \
     open('colores_a_traducir_fix.csv', 'w', newline='', encoding='utf-8-sig') as f_out:
    
    reader = csv.DictReader(f_in)
    fieldnames = reader.fieldnames
    writer = csv.DictWriter(f_out, fieldnames=fieldnames)
    writer.writeheader()
    
    for row in reader:
        color1 = row.get('Color__c', '').strip()
        color2 = row.get('Color2__c', '').strip()
        if color1 or color2:
            writer.writerow(row)
