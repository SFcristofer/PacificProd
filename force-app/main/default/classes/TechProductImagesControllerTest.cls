@isTest(SeeAllData=true)
private class TechProductImagesControllerTest {
    @isTest
    static void testSaveImagesSuccess() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        TechProductImagesController.saveImages(
            prod.Id, 
            'https://onedrive.live.com/test', 
            'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', 
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', 
            null, 
            null
        );
        Test.stopTest();
    }

    @isTest
    static void testSaveImagesException() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        String longLink = '';
        for (Integer i = 0; i < 260; i++) {
            longLink += 'a';
        }
        Test.startTest();
        try {
            TechProductImagesController.saveImages(prod.Id, longLink, null, null, null, null);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testSaveSingleImageSuccess() {
        Product2 prod = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        if (prod.ProductCode == null) {
            prod.ProductCode = 'TEST-12345678';
            update prod;
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TechProductImagesController.saveSingleImage(
            prod.Id,
            1,
            'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
        );
        TechProductImagesController.saveSingleImage(
            prod.Id,
            2,
            'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
        );
        Test.stopTest();
    }

    @isTest
    static void testSaveSingleImageException() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        try {
            // Mandamos base64 corrupto para provocar error
            TechProductImagesController.saveSingleImage(prod.Id, 1, 'bad-base64!');
        } catch (Exception e) {}
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}