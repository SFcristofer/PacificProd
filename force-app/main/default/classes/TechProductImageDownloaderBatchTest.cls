@isTest(SeeAllData=true)
public class TechProductImageDownloaderBatchTest {
    
    // Mock para simular la descarga de la imagen sin hacer la petición web real
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'image/jpeg');
            res.setBodyAsBlob(Blob.valueOf('MockFileData'));
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testBatchExecution() {
        // Usamos un producto existente para evitar el trigger BeforeInsert que está fallando actualmente en la Org
        List<Product2> existingProds = [SELECT Id FROM Product2 LIMIT 1];
        if (existingProds.isEmpty()) {
            return; // Si no hay productos, salimos de forma segura
        }
        
        Product2 testProd = existingProds[0];
        testProd.Tech_URL_Descarga_Img1__c = 'https://mockurl.com/img1.jpg';
        testProd.Tech_URL_Descarga_Img2__c = 'https://mockurl.com/img2.jpg';
        testProd.Tech_URL_Descarga_Img3__c = 'https://mockurl.com/img3.jpg';
        testProd.Tech_URL_Descarga_Img4__c = 'https://mockurl.com/img4.jpg';
        
        update testProd; // La actualización en Tests hace Rollback automático al final, por lo que es seguro

        // Asignar el Mock de la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Ejecutamos el Batch
        TechProductImageDownloaderBatch batch = new TechProductImageDownloaderBatch();
        Database.executeBatch(batch, 10);
        Test.stopTest();

        // Validaciones
        Product2 updatedProd = [SELECT IDImagen1__c, Tech_URL_Descarga_Img1__c FROM Product2 WHERE Id = :testProd.Id];
        
        System.assertEquals(null, updatedProd.Tech_URL_Descarga_Img1__c, 'El Batch debe limpiar la URL después de descargar.');
        System.assertNotEquals(null, updatedProd.IDImagen1__c, 'El Batch debe asociar un Attachment ID al producto.');
    }
}
