Id fabricaRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ProductoDeFabrica').getRecordTypeId();

List<Product2> factories = [
    SELECT ProductoBase__c 
    FROM Product2 
    WHERE RecordTypeId = :fabricaRT
    AND ProductoBase__c != null
    AND (ProductCode = null OR Family = null OR Subfamilia__c = null OR Clase__c = null)
];

Set<Id> baseIds = new Set<Id>();
for (Product2 f : factories) {
    baseIds.add(f.ProductoBase__c);
}

List<AggregateResult> subfams = [SELECT Subfamilia__c, COUNT(Id) total FROM Product2 WHERE Id IN :baseIds GROUP BY Subfamilia__c];
List<AggregateResult> clases = [SELECT Clase__c, COUNT(Id) total FROM Product2 WHERE Id IN :baseIds GROUP BY Clase__c];

System.debug('=== SUBFAMILIAS EN USO ===');
for (AggregateResult ar : subfams) {
    System.debug(ar.get('Subfamilia__c') + ' -> ' + ar.get('total') + ' productos');
}

System.debug('=== CLASES EN USO ===');
for (AggregateResult ar : clases) {
    System.debug(ar.get('Clase__c') + ' -> ' + ar.get('total') + ' productos');
}
