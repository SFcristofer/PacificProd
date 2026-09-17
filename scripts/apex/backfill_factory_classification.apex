// One-time data fix: backfill ProductCode/Family/Subfamilia__c/Clase__c on existing
// factory products (RecordType = ProductoDeFabrica) from their base product.
// Only touches factory records that are still blank on these fields.

Set<String> baseProductCodes = new Set<String>{'H309128S'};

Id baseRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Producto').getRecordTypeId();
Id fabricaRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ProductoDeFabrica').getRecordTypeId();

Map<Id, Product2> bases = new Map<Id, Product2>([SELECT Id, ProductCode, Family, Subfamilia__c, Clase__c
                                                    FROM Product2
                                                    WHERE RecordTypeId = :baseRT
                                                    AND ProductCode IN :baseProductCodes]);

List<Product2> factoryProds = [SELECT Id, Name, ProductoBase__c, ProductCode, Family, Subfamilia__c, Clase__c
                                FROM Product2
                                WHERE RecordTypeId = :fabricaRT
                                AND ProductoBase__c IN :bases.keySet()];

List<Product2> toUpdate = new List<Product2>();
for (Product2 fp : factoryProds) {
    Product2 base = bases.get(fp.ProductoBase__c);
    
    Boolean changed = false;
    if (fp.ProductCode == null) { fp.ProductCode = base.ProductCode; changed = true; }
    if (fp.Family == null) { fp.Family = base.Family; changed = true; }
    if (fp.Subfamilia__c == null) { fp.Subfamilia__c = base.Subfamilia__c; changed = true; }
    if (fp.Clase__c == null) { fp.Clase__c = base.Clase__c; changed = true; }
    
    if (changed) {
        toUpdate.add(fp);
    }
}

System.debug('Productos de fabrica a actualizar: ' + toUpdate.size());

if (!toUpdate.isEmpty()) {
    Database.SaveResult[] results = Database.update(toUpdate, false);
    for (Integer i = 0; i < results.size(); i++) {
        Database.SaveResult r = results[i];
        if (r.isSuccess()) {
            System.debug('OK -> ' + toUpdate[i].Id + ' (' + toUpdate[i].Name + ')');
        } else {
            System.debug('ERROR -> ' + toUpdate[i].Id + ' (' + toUpdate[i].Name + '): ' + r.getErrors());
        }
    }
} else {
    System.debug('No hay productos de fabrica pendientes de actualizar para los codigos: ' + baseProductCodes);
}
