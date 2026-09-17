import pandas as pd
import xml.etree.ElementTree as ET

def get_valid_active_picklists(xml_path):
    valid = set()
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        ns = {'sf': root.tag.split('}')[0].strip('{')}
        values = root.findall('.//sf:valueSetDefinition/sf:value', ns)
        if not values:
            values = root.findall('.//sf:value', ns)
        for val in values:
            full_name = val.find('sf:fullName', ns)
            if full_name is None:
                continue
            is_active = val.find('sf:isActive', ns)
            if is_active is None or is_active.text == 'true':
                valid.add(full_name.text)
    except Exception as e:
        print('Error:', e)
    return valid

valid_sub = get_valid_active_picklists('force-app/main/default/objects/Product2/fields/Subfamilia__c.field-meta.xml')
valid_clase = get_valid_active_picklists('force-app/main/default/objects/Product2/fields/Clase__c.field-meta.xml')

try:
    df = pd.read_csv('Product2.csv', encoding='utf-8', dtype=str)
except:
    df = pd.read_csv('Product2.csv', encoding='latin-1', dtype=str)

def is_invalid(row):
    sub = row.get('Subfamilia__c')
    cla = row.get('Clase__c')
    if pd.notna(sub) and str(sub).strip() and str(sub).strip() not in valid_sub:
        return True
    if pd.notna(cla) and str(cla).strip() and str(cla).strip() not in valid_clase:
        return True
    return False

invalid_mask = df.apply(is_invalid, axis=1)
invalid_df = df[invalid_mask]
invalid_df.to_csv('Productos_Con_Errores_Inactivos.csv', index=False, encoding='utf-8-sig')
print('Total records with errors:', len(invalid_df))

