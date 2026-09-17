import csv

input_file = 'Productos.csv'
output_file = 'Productos_A_Invertir.csv'

with open(input_file, mode='r', encoding='latin1') as infile, open(output_file, mode='w', encoding='utf-8', newline='') as outfile:
    reader = csv.DictReader(infile)
    # Ensure fieldnames exist
    fieldnames = reader.fieldnames
    if not fieldnames:
        fieldnames = ["Id", "Name", "ProductName__c", "ProductCode"]
        
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    writer.writeheader()
    
    count_kept = 0
    count_removed = 0
    for row in reader:
        # Check if ProductName__c is not empty
        val = row.get('ProductName__c', '')
        if val and val.strip() != '':
            writer.writerow(row)
            count_kept += 1
        else:
            count_removed += 1
            
print(f"Productos listos para invertir: {count_kept}")
print(f"Productos ignorados (vacios): {count_removed}")
