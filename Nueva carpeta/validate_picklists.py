import pandas as pd
import xml.etree.ElementTree as ET
import re

def get_valid_picklists(xml_path):
    valid = set()
    try:
        content = open(xml_path, 'r', encoding='utf-8').read()
        matches = re.findall(r'<fullName>(.*?)</fullName>', content)
        # Filter out the field name itself
        valid.update([m for m in matches if not m.endswith('__c')])
    except Exception as e:
        print('Error:', e)
    return valid

valid_sub = get_valid_picklists('force-app/main/default/objects/Product2/fields/Subfamilia__c.field-meta.xml')
valid_clase = get_valid_picklists('force-app/main/default/objects/Product2/fields/Clase__c.field-meta.xml')
print('Valid Subfamilies:', len(valid_sub))
print('Valid Clases:', len(valid_clase))

try:
    df = pd.read_csv('Product2.csv', encoding='latin-1', dtype=str)
except:
    df = pd.read_csv('Product2.csv', encoding='utf-8', dtype=str)
print('Columns:', list(df.columns))

