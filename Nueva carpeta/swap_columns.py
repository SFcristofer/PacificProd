import csv

input_file = 'Productos_A_Invertir.csv'
output_file = 'Productos_Swapped.csv'

with open(input_file, mode='r', encoding='utf-8') as infile, open(output_file, mode='w', encoding='utf-8', newline='') as outfile:
    reader = csv.DictReader(infile)
    # Solo necesitamos mapear Id, Name y ProductName__c para la actualizacion
    writer = csv.DictWriter(outfile, fieldnames=['Id', 'Name', 'ProductName__c'])
    writer.writeheader()
    
    for row in reader:
        original_name = row.get('Name', '')
        original_english = row.get('ProductName__c', '')
        
        # Intercambiamos los valores (solo si el ingles no es muy largo)
        new_name = original_english[:255] if len(original_english) > 255 else original_english
        new_english = original_name
        
        writer.writerow({
            'Id': row['Id'],
            'Name': new_name,
            'ProductName__c': new_english
        })

print("Archivo invertido creado exitosamente.")
