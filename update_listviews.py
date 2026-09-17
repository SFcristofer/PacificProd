import os
import xml.etree.ElementTree as ET

dir_path = r'force-app\main\default\objects\Opportunity\listViews'

mapping = {
    'Todas las oportunidades': 'All Opportunities',
    'Oportunidades 2018': 'Opportunities 2018',
    'Oportunidades 2019': 'Opportunities 2019',
    'Oportunidades 2020': 'Opportunities 2020',
    'Oportunidades 2021': 'Opportunities 2021',
    'Oportunidades 2022': 'Opportunities 2022',
    'Oportunidades 2023': 'Opportunities 2023',
    'Oportunidades 2024': 'Opportunities 2024',
    'Oportunidades 2025': 'Opportunities 2025',
    '2026 - Etapas Clave Todas Oportunidades': '2026 - Key Stages All Opportunities',
    '2026 - Todas las Oportunidades JENNY': '2026 - All Opportunities JENNY',
    '2026 - Todas las Oportunidades MIGUEL': '2026 - All Opportunities MIGUEL',
    '2026 - Todas las Oportunidades VANESSA': '2026 - All Opportunities VANESSA',
    '2027 - Todas las Oportunidades JENNY': '2027 - All Opportunities JENNY',
    '2027 - Todas las Oportunidades MIGUEL': '2027 - All Opportunities MIGUEL',
    '2027 - Todas las Oportunidades VANESSA': '2027 - All Opportunities VANESSA',
    '2027 - Todas Oportunidades': '2027 - All Opportunities'
}

ET.register_namespace('', "http://soap.sforce.com/2006/04/metadata")

for filename in os.listdir(dir_path):
    if filename.endswith('.listView-meta.xml'):
        filepath = os.path.join(dir_path, filename)
        tree = ET.parse(filepath)
        root = tree.getroot()
        
        # Salesforce namespace
        ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
        label_elem = root.find('sf:label', ns)
        
        if label_elem is not None and label_elem.text in mapping:
            label_elem.text = mapping[label_elem.text]
            tree.write(filepath, encoding='UTF-8', xml_declaration=True)
            print(f'Updated {filename}')
