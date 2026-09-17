public with sharing class TechExportRecordsToExcel {

    public class Request {
        @InvocableVariable(required=true label='File Name')
        public String fileName;
        @InvocableVariable(required=true label='Data (JSON array of records)')
        public String dataJson;
        @InvocableVariable(label='Record Id to attach file to')
        public Id recordId;
    }

    public class Response {
        @InvocableVariable(label='File URL')
        public String fileUrl;
        @InvocableVariable(label='Summary')
        public String summary;
    }

    @InvocableMethod(label='Tech - Export Records To Excel' description='Generates a downloadable CSV (Excel-compatible) file from a JSON array of records and optionally attaches it to a Salesforce record.')
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            responses.add(buildFile(req));
        }
        return responses;
    }

    private static Response buildFile(Request req) {
        Response res = new Response();

        List<Object> rows;
        try {
            rows = (List<Object>) JSON.deserializeUntyped(req.dataJson);
        } catch (Exception e) {
            res.summary = 'El formato de los datos no es un arreglo JSON válido.';
            return res;
        }

        if (rows == null || rows.isEmpty()) {
            res.summary = 'No hay datos para exportar.';
            return res;
        }

        Map<String, Object> firstRow = (Map<String, Object>) rows[0];
        List<String> headers = new List<String>(firstRow.keySet());

        List<String> lines = new List<String>();
        lines.add(String.join(headers, ','));
        for (Object rowObj : rows) {
            Map<String, Object> row = (Map<String, Object>) rowObj;
            List<String> values = new List<String>();
            for (String header : headers) {
                Object val = row.get(header);
                values.add(toCsvCell(val));
            }
            lines.add(String.join(values, ','));
        }
        String csv = String.join(lines, '\n');

        String safeName = String.isNotBlank(req.fileName) ? req.fileName : 'Reporte';

        ContentVersion cv = new ContentVersion();
        cv.Title = safeName;
        cv.PathOnClient = safeName + '.csv';
        cv.VersionData = Blob.valueOf(csv);
        insert cv;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        if (req.recordId != null) {
            insert new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = req.recordId,
                ShareType = 'V'
            );
        }

        res.fileUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/ContentDocument/' + contentDocumentId + '/view';
        res.summary = 'Archivo "' + safeName + '.csv" generado correctamente (' + rows.size() + ' filas). Se puede abrir directamente en Excel.';
        return res;
    }

    private static String toCsvCell(Object val) {
        String cell = val == null ? '' : String.valueOf(val);
        cell = cell.replace('"', '""');
        if (cell.contains(',') || cell.contains('\n') || cell.contains('"')) {
            cell = '"' + cell + '"';
        }
        return cell;
    }
}
