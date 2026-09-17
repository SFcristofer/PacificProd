import os
import xml.etree.ElementTree as ET

dir_path = r'force-app\main\default\objects\PedidoDeCompra__c\listViews'

mapping = {
    'TODOS LOS PEDIDOS': 'ALL ORDERS',
    'Pedidos 2018': 'Orders 2018',
    'Pedidos 2019': 'Orders 2019',
    'Pedidos 2020': 'Orders 2020',
    'Pedidos 2021': 'Orders 2021',
    'Pedidos 2022': 'Orders 2022',
    'Pedidos 2023': 'Orders 2023',
    'Pedidos 2024': 'Orders 2024',
    'Pedidos 2025': 'Orders 2025',
    '2026 - Todos los Pedidos': '2026 - All Orders',
    '2026 - Todos los Pedidos COMPRAS': '2026 - All Orders PURCHASING',
    '2027 - Todos los Pedidos': '2027 - All Orders',
    '2026 - CONTROL BOOKINGS': '2026 - BOOKINGS CONTROL',
    '2026 - CONTROL EMBARQUES': '2026 - SHIPMENTS CONTROL',
    '2026 - CONTROL INSPECCIONES': '2026 - INSPECTIONS CONTROL',
    '2026 - CONTROL PAGO INSPECCIONES': '2026 - INSPECTIONS PAYMENT CONTROL',
    '2026 - CONTROL PACKAGING': '2026 - PACKAGING CONTROL',
    'PACKAGINGS': 'PACKAGINGS',
    'PACKAGING PURCHASES': 'PACKAGING PURCHASES',
    'PACKAGING DISEÑADORES GRÁFICOS': 'PACKAGING GRAPHIC DESIGNERS',
    'PACKAGING KAMs': 'PACKAGING KAMs',
    'Pedidos EMBARCADOS pendiente BALANCE': 'SHIPPED Orders Pending BALANCE',
    'Simulaciones': 'Simulations'
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
