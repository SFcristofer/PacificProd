@isTest
private class TechGetRelatedNotesAndFilesTest {

    @isTest
    static void testNoRelatedContent() {
        Account acc = new Account(Name = 'Test Account NRNF');
        insert acc;

        TechGetRelatedNotesAndFiles.Request req = new TechGetRelatedNotesAndFiles.Request();
        req.recordId = acc.Id;

        Test.startTest();
        List<TechGetRelatedNotesAndFiles.Response> results = TechGetRelatedNotesAndFiles.execute(
            new List<TechGetRelatedNotesAndFiles.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(
            'No hay notas ni archivos adjuntos relacionados con este registro.',
            results[0].summary
        );
    }

    @isTest
    static void testRelatedNoteAndFile() {
        Account acc = new Account(Name = 'Test Account NRNF 2');
        insert acc;

        ContentNote note = new ContentNote(Title = 'Nota de prueba', Content = Blob.valueOf('<p>Contenido de prueba</p>'));
        insert note;

        ContentVersion version = new ContentVersion(
            Title = 'Cotizacion',
            PathOnClient = 'Cotizacion.pdf',
            VersionData = Blob.valueOf('PDF FAKE CONTENT'),
            IsMajorVersion = true
        );
        insert version;
        Id fileContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id].ContentDocumentId;

        Id noteContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :note.Id LIMIT 1].ContentDocumentId;

        insert new List<ContentDocumentLink>{
            new ContentDocumentLink(ContentDocumentId = noteContentDocumentId, LinkedEntityId = acc.Id, ShareType = 'V'),
            new ContentDocumentLink(ContentDocumentId = fileContentDocumentId, LinkedEntityId = acc.Id, ShareType = 'V')
        };

        TechGetRelatedNotesAndFiles.Request req = new TechGetRelatedNotesAndFiles.Request();
        req.recordId = acc.Id;

        Test.startTest();
        List<TechGetRelatedNotesAndFiles.Response> results = TechGetRelatedNotesAndFiles.execute(
            new List<TechGetRelatedNotesAndFiles.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].summary.contains('Nota de prueba'));
        System.assert(results[0].summary.contains('Contenido de prueba'));
        System.assert(results[0].summary.contains('Cotizacion'));
    }
}
