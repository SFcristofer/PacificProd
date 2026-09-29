import os

controller_path = r"force-app\main\default\classes\ProductExtensionController.cls"
with open(controller_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Update initial query fields
content = content.replace(
    "Descripcion_Larga__c, \n                            Thumb1__c, \n                            CodigoDeProductoBase__c, \n                            ProductoBase__r.Marca__c, \n                            ProductoBase__r.unidadescontainer20__c, \n                            ProductoBase__r.unidadescontainer40__c, \n                            ProductoBase__r.unidadeshq__c,",
    "Description, \n                            Thumb1__c, \n                            CodigoDeProductoBase__c, \n                            ProductoBase__r.Marca__c, \n                            Familia_producto_base__c, \n                            Subfamilia__c, \n                            Clase__c,"
)
content = content.replace("ORDER BY Descripcion_Larga__c", "ORDER BY Description")

# 2. Update search query
old_search_logic = """        if(prodSearch != null && (prodSearch).trim() !='')
        {
            strFilter = '((';
            Integer i = 0;
            for(String s : prodSearch.trim().split(' ')){
                if(i > 0){
                    strFilter += ' AND ';
                }
                strFilter += 'Descripcion_Larga__c Like \\'%' + s + '%\\'';
                i++;
            }
            strFilter += ') OR CodigoDeProductoBase__c Like \\'%' + prodSearch.trim() + '%\\')';
            
        }

        query = 'SELECT Id, Name, Descripcion_Larga__c, Thumb1__c, CodigoDeProductoBase__c, ProductoBase__r.Marca__c,'
                + ' ProductoBase__r.Unidadescontainer20__c, ProductoBase__r.unidadescontainer40__c,' 
                + ' ProductoBase__r.unidadeshq__c, IsActive FROM Product2 WHERE IsActive = true'
                + ' AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE CurrencyISOCode = \\'' + opp.CurrencyISOCode +'\\')';"""

new_search_logic = """        if(prodSearch != null && (prodSearch).trim() !='')
        {
            strFilter = '((';
            Integer i = 0;
            for(String s : prodSearch.trim().split(' ')){
                if(i > 0){
                    strFilter += ' AND ';
                }
                strFilter += '(Description Like \\'%' + s + '%\\' OR Familia_producto_base__c Like \\'%' + s + '%\\' OR Subfamilia__c Like \\'%' + s + '%\\' OR Clase__c Like \\'%' + s + '%\\')';
                i++;
            }
            strFilter += ') OR CodigoDeProductoBase__c Like \\'%' + prodSearch.trim() + '%\\' OR ProductoBase__r.Marca__c Like \\'%' + prodSearch.trim() + '%\\')';
            
        }

        query = 'SELECT Id, Name, Description, Thumb1__c, CodigoDeProductoBase__c, ProductoBase__r.Marca__c,'
                + ' Familia_producto_base__c, Subfamilia__c, Clase__c, IsActive FROM Product2 WHERE IsActive = true'
                + ' AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE CurrencyISOCode = \\'' + opp.CurrencyISOCode +'\\')';"""

content = content.replace(old_search_logic, new_search_logic)

# 3. Update setupListHybridProducts query
content = content.replace(
    "Product2.Descripcion_Larga__c, \n                                     Product2.Thumb1__c, \n                                     Product2.CodigoDeProductoBase__c, \n                                     Product2.ProductoBase__r.Marca__c, \n                                     Product2.ProductoBase__r.Unidadescontainer20__c, \n                                     Product2.ProductoBase__r.Unidadescontainer40__c, \n                                     Product2.ProductoBase__r.Unidadeshq__c,",
    "Product2.Description, \n                                     Product2.Thumb1__c, \n                                     Product2.CodigoDeProductoBase__c, \n                                     Product2.ProductoBase__r.Marca__c, \n                                     Product2.Familia_producto_base__c, \n                                     Product2.Subfamilia__c, \n                                     Product2.Clase__c,"
)
content = content.replace("ORDER BY Product2.Descripcion_Larga__c", "ORDER BY Product2.Description")

with open(controller_path, "w", encoding="utf-8") as f:
    f.write(content)


# --- Now FindProducts.page ---
page_path = r"force-app\main\default\pages\FindProducts.page"
with open(page_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace Descripcion_Larga__c with Description
content = content.replace("prodSel.Descripcion_Larga__c", "prodSel.Description")
content = content.replace("prod.Descripcion_Larga__c", "prod.Description")
content = content.replace("hybridProd.product.Descripcion_Larga__c", "hybridProd.product.Description")

# Change DO Code to PG Code
content = content.replace('headerValue="DO Code"', 'headerValue="PG Code"')
content = content.replace('<apex:facet name="header">DO Code</apex:facet>', '<apex:facet name="header">PG Code</apex:facet>')

# First table: remove units, add family/sub/class
table1_old = """            <apex:column value="{!prod.ProductoBase__r.UnidadesContainer20__c}" headerValue="20' Units"/>
            <apex:column value="{!prod.ProductoBase__r.UnidadesContainer40__c}" headerValue="40' Units"/>
            <apex:column value="{!prod.ProductoBase__r.UnidadesHQ__c}" headerValue="HQ Units"/>"""
table1_new = """            <apex:column value="{!prod.Familia_producto_base__c}" headerValue="Family"/>
            <apex:column value="{!prod.Subfamilia__c}" headerValue="Subfamily"/>
            <apex:column value="{!prod.Clase__c}" headerValue="Class"/>"""
content = content.replace(table1_old, table1_new)

# Second table (hybridProducts): remove units, add family/sub/class
table2_old = """         <apex:column >
            <apex:facet name="header">20' Units</apex:facet>
            <apex:outputText value="{!hybridProd.product.ProductoBase__r.UnidadesContainer20__c}"/>
         </apex:column>

         <apex:column >
            <apex:facet name="header">40' Units</apex:facet>
            <apex:outputText value="{!hybridProd.product.ProductoBase__r.UnidadesContainer40__c}"/>
         </apex:column>

         <apex:column >
            <apex:facet name="header">HQ Units</apex:facet>
            <apex:outputText value="{!hybridProd.product.ProductoBase__r.UnidadesHQ__c}"/>
         </apex:column>"""

table2_new = """         <apex:column >
            <apex:facet name="header">Family</apex:facet>
            <apex:outputText value="{!hybridProd.product.Familia_producto_base__c}"/>
         </apex:column>

         <apex:column >
            <apex:facet name="header">Subfamily</apex:facet>
            <apex:outputText value="{!hybridProd.product.Subfamilia__c}"/>
         </apex:column>

         <apex:column >
            <apex:facet name="header">Class</apex:facet>
            <apex:outputText value="{!hybridProd.product.Clase__c}"/>
         </apex:column>"""
content = content.replace(table2_old, table2_new)

with open(page_path, "w", encoding="utf-8") as f:
    f.write(content)
