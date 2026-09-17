@isTest
private class TechExportRecordsToExcelTest {

    @isTest
    static void testEmptyData() {
        TechExportRecordsToExcel.Request req = new TechExportRecordsToExcel.Request();
        req.fileName = 'Reporte Vacio';
        req.dataJson = '[]';

        Test.startTest();
        List<TechExportRecordsToExcel.Response> results = TechExportRecordsToExcel.execute(
            new List<TechExportRecordsToExcel.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('No hay datos para exportar.', results[0].summary);
        System.assertEquals(null, results[0].fileUrl);
    }

    @isTest
    static void testInvalidJson() {
        TechExportRecordsToExcel.Request req = new TechExportRecordsToExcel.Request();
        req.fileName = 'Reporte Invalido';
        req.dataJson = 'no es json';

        Test.startTest();
        List<TechExportRecordsToExcel.Response> results = TechExportRecordsToExcel.execute(
            new List<TechExportRecordsToExcel.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].summary.contains('no es un arreglo JSON'));
    }

    @isTest
    static void testValidDataWithoutRecordId() {
        TechExportRecordsToExcel.Request req = new TechExportRecordsToExcel.Request();
        req.fileName = 'Ventas Walmart 2026';
        req.dataJson = '[{"Cliente":"Walmart","Importe":"1000"},{"Cliente":"Soriana, S.A.","Importe":"2500"}]';

        Test.startTest();
        List<TechExportRecordsToExcel.Response> results = TechExportRecordsToExcel.execute(
            new List<TechExportRecordsToExcel.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].summary.contains('2 filas'));
        System.assert(results[0].fileUrl != null);
        System.assert(results[0].fileUrl.contains('/lightning/r/ContentDocument/'));

        List<ContentVersion> versions = [SELECT Title, PathOnClient FROM ContentVersion WHERE Title = 'Ventas Walmart 2026'];
        System.assertEquals(1, versions.size());
        System.assertEquals('Ventas Walmart 2026.csv', versions[0].PathOnClient);
    }

    @isTest
    static void testValidDataWithRecordId() {
        Account acc = new Account(Name = 'Test Account Export');
        insert acc;

        TechExportRecordsToExcel.Request req = new TechExportRecordsToExcel.Request();
        req.fileName = 'Reporte Cuenta';
        req.dataJson = '[{"Producto":"SKU-1","Unidades":"10"}]';
        req.recordId = acc.Id;

        Test.startTest();
        List<TechExportRecordsToExcel.Response> results = TechExportRecordsToExcel.execute(
            new List<TechExportRecordsToExcel.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].fileUrl != null);

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Reporte Cuenta' LIMIT 1].ContentDocumentId;
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :acc.Id];
        System.assertEquals(1, links.size());
    }
}
