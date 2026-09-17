import xml.etree.ElementTree as ET
import os
import math

def split_package_xml(file_path, max_items_per_chunk=3000):
    tree = ET.parse(file_path)
    root = tree.getroot()
    namespace = {'xmlns': 'http://soap.sforce.com/2006/04/metadata'}
    ET.register_namespace('', namespace['xmlns'])

    version = root.find('{http://soap.sforce.com/2006/04/metadata}version').text

    types = root.findall('{http://soap.sforce.com/2006/04/metadata}types')
    
    current_chunk = 1
    current_items = 0
    
    def create_new_root():
        new_root = ET.Element('Package', xmlns="http://soap.sforce.com/2006/04/metadata")
        return new_root
    
    def save_chunk(root_element, chunk_idx):
        ver_elem = ET.SubElement(root_element, 'version')
        ver_elem.text = version
        tree = ET.ElementTree(root_element)
        # Using encoding and xml_declaration to match SF format
        tree.write(f'manifest/package_{chunk_idx}.xml', encoding='UTF-8', xml_declaration=True)
        print(f"Created manifest/package_{chunk_idx}.xml")

    current_root = create_new_root()
    
    for type_elem in types:
        name_elem = type_elem.find('{http://soap.sforce.com/2006/04/metadata}name')
        members = type_elem.findall('{http://soap.sforce.com/2006/04/metadata}members')
        
        # If the type has fewer than max_items, we can just add it or split its members
        # To be safe, we split members into chunks if needed
        for i in range(0, len(members), max_items_per_chunk):
            chunk_members = members[i:i + max_items_per_chunk]
            
            if current_items + len(chunk_members) > max_items_per_chunk:
                save_chunk(current_root, current_chunk)
                current_chunk += 1
                current_root = create_new_root()
                current_items = 0
                
            new_type = ET.SubElement(current_root, 'types')
            for member in chunk_members:
                new_member = ET.SubElement(new_type, 'members')
                new_member.text = member.text
            new_name = ET.SubElement(new_type, 'name')
            new_name.text = name_elem.text
            
            current_items += len(chunk_members)

    if current_items > 0:
        save_chunk(current_root, current_chunk)

if __name__ == "__main__":
    if not os.path.exists("manifest"):
        os.makedirs("manifest")
    split_package_xml("manifest/package.xml", 2000)
