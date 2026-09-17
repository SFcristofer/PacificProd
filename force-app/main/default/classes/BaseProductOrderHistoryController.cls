public with sharing class BaseProductOrderHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<PedidoLineItem__c> getOrderHistory(Id baseProductId) {
        List<Product2> factoryProducts = [SELECT Id FROM Product2 WHERE ProductoBase__c = :baseProductId AND RecordType.DeveloperName = 'ProductoDeFabrica'];
        Set<Id> factoryIds = new Set<Id>();
        for (Product2 p : factoryProducts) {
            factoryIds.add(p.Id);
        }
        
        if(factoryIds.isEmpty()){
            return new List<PedidoLineItem__c>();
        }
        
        return [SELECT Id, PedidoDeCompra__c, PedidoDeCompra__r.Name, Producto__c, Producto__r.Name, Producto__r.Fabrica__r.Name, Unidades__c, PrecioDeVenta__c 
                FROM PedidoLineItem__c 
                WHERE Producto__c IN :factoryIds 
                ORDER BY CreatedDate DESC LIMIT 50];
    }
}
