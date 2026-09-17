List<Product2> factories = [SELECT ProductoBase__c FROM Product2 WHERE Estatus__c = 'Primary' AND ProductoBase__c != null];
Set<Id> baseIds = new Set<Id>();
for(Product2 p : factories) { baseIds.add(p.ProductoBase__c); }

Integer baseProdsFaltantes = [
    SELECT count() 
    FROM Product2 
    WHERE Id IN :baseIds
    AND (Fabrica__c = null OR Codigo_Proveedor__c = null)
];

Id fabricaRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ProductoDeFabrica').getRecordTypeId();
Integer factoryProdsFaltantes = [
    SELECT count() 
    FROM Product2 
    WHERE RecordTypeId = :fabricaRT
    AND ProductoBase__c != null
    AND (ProductCode = null OR Family = null OR Subfamilia__c = null OR Clase__c = null)
];

System.debug('====== RESULTADOS DEL DIAGNÓSTICO ======');
System.debug('Productos Base sin datos de proveedor: ' + baseProdsFaltantes);
System.debug('Productos de Fábrica sin datos de clasificación: ' + factoryProdsFaltantes);
System.debug('========================================');
