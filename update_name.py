import os

controller_path = r"force-app\main\default\classes\ProductExtensionController.cls"
with open(controller_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace Description with Name in strFilter
content = content.replace("Description Like", "Name Like")
# Replace ORDER BY Description with ORDER BY Name
content = content.replace("ORDER BY Description", "ORDER BY Name")
content = content.replace("ORDER BY Product2.Description", "ORDER BY Product2.Name")

with open(controller_path, "w", encoding="utf-8") as f:
    f.write(content)


page_path = r"force-app\main\default\pages\FindProducts.page"
with open(page_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace Description with Name
content = content.replace("prodSel.Description", "prodSel.Name")
content = content.replace("prod.Description", "prod.Name")
content = content.replace("hybridProd.product.Description", "hybridProd.product.Name")

with open(page_path, "w", encoding="utf-8") as f:
    f.write(content)
