public with sharing class TechGetRelatedNotesAndFiles {

    public class Request {
        @InvocableVariable(required=true label='Record Id')
        public Id recordId;
    }

    public class Response {
        @InvocableVariable(label='Summary')
        public String summary;
    }

    @InvocableMethod(label='Tech - Get Related Notes And Files' description='Returns the text of Enhanced Notes and the list of attached files linked to a Task, Event, Opportunity or other Salesforce record.')
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            responses.add(buildResponse(req.recordId));
        }
        return responses;
    }

    private static Response buildResponse(Id recordId) {
        Response res = new Response();
        List<String> parts = new List<String>();

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];

        if (links.isEmpty()) {
            res.summary = 'No hay notas ni archivos adjuntos relacionados con este registro.';
            return res;
        }

        Set<Id> noteDocIds = new Set<Id>();
        List<String> fileNames = new List<String>();
        for (ContentDocumentLink link : links) {
            if (link.ContentDocument.FileType == 'SNOTE') {
                noteDocIds.add(link.ContentDocumentId);
            } else {
                fileNames.add(link.ContentDocument.Title + ' (' + link.ContentDocument.FileType + ')');
            }
        }

        if (!noteDocIds.isEmpty()) {
            for (ContentNote note : [SELECT Title, Content FROM ContentNote WHERE Id IN :noteDocIds]) {
                String bodyText = note.Content != null
                    ? note.Content.toString().replaceAll('<[^>]+>', ' ').trim()
                    : '';
                parts.add('Nota "' + note.Title + '": ' + bodyText);
            }
        }

        if (!fileNames.isEmpty()) {
            parts.add('Archivos adjuntos: ' + String.join(fileNames, ', '));
        }

        res.summary = parts.isEmpty()
            ? 'No hay notas ni archivos adjuntos relacionados con este registro.'
            : String.join(parts, '\n');
        return res;
    }
}
