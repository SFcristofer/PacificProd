@isTest
private class TestCloneProduct {
	
	@isTest static void testNewBrand() {
		TestUtil tu = new TestUtil();
        tu.initTestData();
        list<Product2> lp = [SELECT Id
                            FROM Product2
                            WHERE RecordType.DeveloperName = 'Producto'];
        system.assertEquals(lp.size(), 2);
        test.startTest();
        CloneProduct cp = new CloneProduct(new ApexPages.StandardController(lp[0]));
        cp.newBrand = cp.altBrands[0].getLabel();
        cp.setMBrand();
        cp.cloneWithFactory();
        test.stopTest();
        lp = [SELECT Id
                    FROM Product2
                    WHERE RecordType.DeveloperName = 'Producto'];
        system.assertEquals(lp.size(), 3);
	}
	
	@isTest static void testNewColor() {
		TestUtil tu = new TestUtil();
        tu.initTestData();
        list<Product2> lp = [SELECT Id
                            FROM Product2
                            WHERE RecordType.DeveloperName = 'Producto'];
        system.assertEquals(lp.size(), 2);
        test.startTest();
        tu.createProductoBaseImage();
        CloneProduct cp = new CloneProduct(new ApexPages.StandardController(lp[0]));
        cp.newColor = 'GOLD';
        cp.setMColor();
        cp.cloneWithFactory();
        test.stopTest();
        lp = [SELECT Id
                    FROM Product2
                    WHERE RecordType.DeveloperName = 'Producto'];
        //system.assertEquals(lp.size(), 3);
	}

	@isTest static void testNewBrandFromFactory() {
		TestUtil tu = new TestUtil();
        tu.initTestData();
        Product2 factory = [SELECT Id, ProductoBase__c, Fabrica__c
                            FROM Product2
                            WHERE RecordType.DeveloperName = 'ProductoDeFabrica' AND IsActive = true
                            LIMIT 1];
        Map<Id, Product2> oldBases = new Map<Id, Product2>([SELECT Id FROM Product2
                                                            WHERE RecordType.DeveloperName = 'Producto']);
        test.startTest();
        CloneProduct cp = new CloneProduct(new ApexPages.StandardController(factory));
        cp.newBrand = cp.altBrands[0].getLabel();
        cp.setMBrand();
        cp.cloneWithFactory();
        test.stopTest();
        list<Product2> lp = [SELECT Id
                            FROM Product2
                            WHERE RecordType.DeveloperName = 'Producto'];
        system.assertEquals(3, lp.size());
        Product2 newBase = [SELECT Id FROM Product2
                            WHERE RecordType.DeveloperName = 'Producto' AND Id NOT IN :oldBases.keySet()];
        list<Product2> newFactories = [SELECT Fabrica__c FROM Product2 WHERE ProductoBase__c = :newBase.Id];
        system.assertEquals(1, newFactories.size());
        system.assertEquals(factory.Fabrica__c, newFactories[0].Fabrica__c);
        system.assertEquals(1, [SELECT COUNT() FROM Product2 WHERE ProductoBase__c = :factory.ProductoBase__c]);
	}

}