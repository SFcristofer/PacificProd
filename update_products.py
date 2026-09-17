import os
import xml.etree.ElementTree as ET

paths = [
    r'force-app\main\default\objects\Product2\listViews\AllProducts.listView-meta.xml',
    r'force-app\main\default\objects\Product2\listViews\Nuevos_Productos_ltimos_30_d_as.listView-meta.xml',
    r'force-app\main\default\objects\Product2\listViews\Productos_Fabrica.listView-meta.xml',
    r'force-app\main\default\objects\Product2\listViews\Prospectos_de_Producto.listView-meta.xml'
]

mapping = {
    'Todos los productos': 'All Products',
    'Nuevos Productos 2023': 'New Products 2023',
    'Productos Activos': 'Active Products',
    'Prospectos de Producto': 'Product Prospects'
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
