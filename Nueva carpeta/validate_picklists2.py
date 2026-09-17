import pandas as pd
import html
import re

def get_valid_picklists(xml_path):
    valid = set()
    try:
        content = open(xml_path, 'r', encoding='utf-8').read()
        matches = re.findall(r'<fullName>(.*?)</fullName>', content)
        valid.update([html.unescape(m) for m in matches if not m.endswith('__c')])
    except Exception as e:
        pass
    return valid

valid_sub = get_valid_picklists('force-app/main/default/objects/Product2/fields/Subfamilia__c.field-meta.xml')
valid_clase = get_valid_picklists('force-app/main/default/objects/Product2/fields/Clase__c.field-meta.xml')

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
invalid_df.to_csv('Productos_Con_Errores_Clasificacion.csv', index=False, encoding='utf-8-sig')
print('Total records with errors:', len(invalid_df))

