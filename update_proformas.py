import os
import xml.etree.ElementTree as ET

dir_path = r'force-app\main\default\objects\Proforma__c\listViews'

mapping = {
    'Proformas 2018': 'Proformas 2018',
    'Proformas 2019': 'Proformas 2019',
    'Proformas 2020': 'Proformas 2020',
    'Proformas 2021': 'Proformas 2021',
    'Proformas 2022': 'Proformas 2022',
    'Proformas 2023': 'Proformas 2023',
    'Proformas 2024': 'Proformas 2024',
    'Proformas 2025': 'Proformas 2025',
    '2026 - Todas las Proformas': '2026 - All Proformas',
    'PRs Confirmación Subida/Falta Aprobar': 'PRs Upload Confirmation/Pending Approval',
    'PRs Confirmación Subida SIN CHECK': 'PRs Upload Confirmation WITHOUT CHECK'
}

ET.register_namespace('', "http://soap.sforce.com/2006/04/metadata")

for filename in os.listdir(dir_path):
    if filename.endswith('.listView-meta.xml'):
        filepath = os.path.join(dir_path, filename)
        tree = ET.parse(filepath)
        root = tree.getroot()
        
        ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
        label_elem = root.find('sf:label', ns)
        
        if label_elem is not None and label_elem.text in mapping:
            label_elem.text = mapping[label_elem.text]
            tree.write(filepath, encoding='UTF-8', xml_declaration=True)
            print(f'Updated {filename}')
