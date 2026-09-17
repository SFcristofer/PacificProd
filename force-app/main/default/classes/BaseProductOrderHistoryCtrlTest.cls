@isTest(SeeAllData=true)
private class BaseProductOrderHistoryCtrlTest {
    
    @isTest
    static void testGetOrderHistory() {
        // Buscamos un producto base que tenga un producto de fabrica con pedidos
        List<PedidoLineItem__c> items = [SELECT Producto__c, Producto__r.ProductoBase__c FROM PedidoLineItem__c WHERE Producto__r.ProductoBase__c != null LIMIT 1];
        if(!items.isEmpty()) {
            Id baseProdId = items[0].Producto__r.ProductoBase__c;
            
            Test.startTest();
            List<PedidoLineItem__c> result = BaseProductOrderHistoryController.getOrderHistory(baseProdId);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.size() > 0, 'Result should have at least one history record');
        }
    }
    
    @isTest
    static void testGetOrderHistoryNoFactories() {
        List<Product2> baseProds = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Producto' LIMIT 1];
        if(!baseProds.isEmpty()) {
            Id baseProdId = baseProds[0].Id;
            
            Test.startTest();
            List<PedidoLineItem__c> result = BaseProductOrderHistoryController.getOrderHistory(baseProdId);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }
}
