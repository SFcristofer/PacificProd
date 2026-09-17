import os
import xml.etree.ElementTree as ET

paths = [
    r'force-app\main\default\objects\Muestra__c\listViews\Muestras_Enviadas_Seguimiento_DHL.listView-meta.xml',
    r'force-app\main\default\objects\Muestra__c\listViews\Todas_las_Muestras_Vista_Ventas.listView-meta.xml',
    r'force-app\main\default\objects\Solicitud_de_Muestra__c\listViews\All.listView-meta.xml'
]

mapping = {
    'Muestras Enviadas (Seguimiento DHL)': 'Samples Shipped (DHL Tracking)',
    'Todas las Muestras': 'All Samples',
    'Todos': 'All Sample Requests'
}

ET.register_namespace('', "http://soap.sforce.com/2006/04/metadata")

for filepath in paths:
    if os.path.exists(filepath):
        tree = ET.parse(filepath)
        root = tree.getroot()
        ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
        label_elem = root.find('sf:label', ns)
        
        if label_elem is not None and label_elem.text in mapping:
            label_elem.text = mapping[label_elem.text]
            tree.write(filepath, encoding='UTF-8', xml_declaration=True)
            print(f'Updated {filepath}')
