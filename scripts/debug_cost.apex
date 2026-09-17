EscandalloLineItem__c item = [SELECT Id, 
    Producto__r.Name, 
    PrecioCompraFabrica__c, 
    Escandallo__r.ComisionAdministrativa__c, 
    Producto__r.UnidadesContainer20__c, 
    CostoImportacionUnidad__c,
    Costos_Extra__c,
    Gastos_Bancarios__c,
    Escandallo__r.GastosEnPuerto__c,
    Escandallo__r.GastosInspeccion__c,
    Escandallo__r.OtrosCostos__c
    FROM EscandalloLineItem__c WHERE Id = 'a0A4w00000no8S5EAI'];

System.debug('--- DEBUGGING COST ---');
System.debug('PrecioCompraFabrica__c: ' + item.PrecioCompraFabrica__c);
System.debug('Escandallo__r.ComisionAdministrativa__c: ' + item.Escandallo__r.ComisionAdministrativa__c);
System.debug('Producto__r.UnidadesContainer20__c: ' + item.Producto__r.UnidadesContainer20__c);
System.debug('CostoImportacionUnidad__c (Formula real): ' + item.CostoImportacionUnidad__c);
System.debug('Costos_Extra__c (Formula): ' + item.Costos_Extra__c);
System.debug('Gastos_Bancarios__c (Formula): ' + item.Gastos_Bancarios__c);
System.debug('Escandallo__r.GastosEnPuerto__c: ' + item.Escandallo__r.GastosEnPuerto__c);
System.debug('Escandallo__r.GastosInspeccion__c: ' + item.Escandallo__r.GastosInspeccion__c);
System.debug('Escandallo__r.OtrosCostos__c: ' + item.Escandallo__r.OtrosCostos__c);

Decimal term1 = (item.PrecioCompraFabrica__c != null ? item.PrecioCompraFabrica__c : 0) * (item.Escandallo__r.ComisionAdministrativa__c != null ? item.Escandallo__r.ComisionAdministrativa__c : 0);
Decimal term2 = (item.Costos_Extra__c != null ? item.Costos_Extra__c : 0) / (item.Producto__r.UnidadesContainer20__c != null && item.Producto__r.UnidadesContainer20__c != 0 ? item.Producto__r.UnidadesContainer20__c : 1);

System.debug('Term 1 (Precio * Comision): ' + term1);
System.debug('Term 2 (Costos Extra / Unidades): ' + term2);
System.debug('Total Calculado en Script: ' + (term1 + term2));
