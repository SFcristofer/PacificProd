/**
 * @description: 
 * Batch Apex "TechProductImageDownloaderBatch"
 * PROPÓSITO: Leer URLs temporales desde el objeto Product2 (insertadas vía CSV), 
 * hacer la petición HTTP para descargar la imagen real, adjuntarla como Attachment, 
 * y asociar el ID en los campos nativos (IDImagen1__c, etc).
 * 
 * PRECAUCIÓN ORG PERSONALIZADA: 
 * 1. Para evitar impactar la org, la lógica está aislada en este Batch y no en Triggers.
 * 2. Se exige correr el Batch con un tamaño (scope) máximo de 20 para no romper el límite de Callouts de Salesforce.
 *    Para ejecutarlo: Database.executeBatch(new TechProductImageDownloaderBatch(), 20);
 * 3. ANTES DE EJECUTAR, debes crear los siguientes 4 campos personalizados en Product2 (Tipo: URL, Longitud: 255):
 *    - Tech_URL_Descarga_Img1__c
 *    - Tech_URL_Descarga_Img2__c
 *    - Tech_URL_Descarga_Img3__c
 *    - Tech_URL_Descarga_Img4__c
 */
public class TechProductImageDownloaderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Uso de SOQL Dinámico para evitar fallos de despliegue si los campos aún no existen.
        String query = 'SELECT Id, IDImagen1__c, IDImagen2__c, IDImagen3__c, IDImagen4__c ';
        query += ', Tech_URL_Descarga_Img1__c, Tech_URL_Descarga_Img2__c, Tech_URL_Descarga_Img3__c, Tech_URL_Descarga_Img4__c ';
        query += 'FROM Product2 ';
        query += 'WHERE Tech_URL_Descarga_Img1__c != null ';
        query += 'OR Tech_URL_Descarga_Img2__c != null ';
        query += 'OR Tech_URL_Descarga_Img3__c != null ';
        query += 'OR Tech_URL_Descarga_Img4__c != null';
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Product2> productsToUpdate = new List<Product2>();

        for (Product2 prod : scope) {
            Product2 prodUpdate = new Product2(Id = prod.Id);
            Boolean needUpdate = false;

            // Procesar Imagen 1
            if (prod.get('Tech_URL_Descarga_Img1__c') != null) {
                String url = (String)prod.get('Tech_URL_Descarga_Img1__c');
                Attachment att = downloadImage(url, prod.Id, 'Imagen1.jpg');
                if (att != null) attachmentsToInsert.add(att);
                prodUpdate.put('Tech_URL_Descarga_Img1__c', null); // Limpiar URL procesada
                needUpdate = true;
            }

            // Procesar Imagen 2
            if (prod.get('Tech_URL_Descarga_Img2__c') != null) {
                String url = (String)prod.get('Tech_URL_Descarga_Img2__c');
                Attachment att = downloadImage(url, prod.Id, 'Imagen2.jpg');
                if (att != null) attachmentsToInsert.add(att);
                prodUpdate.put('Tech_URL_Descarga_Img2__c', null);
                needUpdate = true;
            }

            // Procesar Imagen 3
            if (prod.get('Tech_URL_Descarga_Img3__c') != null) {
                String url = (String)prod.get('Tech_URL_Descarga_Img3__c');
                Attachment att = downloadImage(url, prod.Id, 'Imagen3.jpg');
                if (att != null) attachmentsToInsert.add(att);
                prodUpdate.put('Tech_URL_Descarga_Img3__c', null);
                needUpdate = true;
            }

            // Procesar Imagen 4
            if (prod.get('Tech_URL_Descarga_Img4__c') != null) {
                String url = (String)prod.get('Tech_URL_Descarga_Img4__c');
                Attachment att = downloadImage(url, prod.Id, 'Imagen4.jpg');
                if (att != null) attachmentsToInsert.add(att);
                prodUpdate.put('Tech_URL_Descarga_Img4__c', null);
                needUpdate = true;
            }

            if (needUpdate) {
                productsToUpdate.add(prodUpdate);
            }
        }

        // Insertar las imágenes descargadas en Salesforce
        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
            
            // Relacionar el ID del Attachment creado con el campo del producto
            for (Attachment att : attachmentsToInsert) {
                for (Product2 p : productsToUpdate) {
                    if (p.Id == att.ParentId) {
                        if (att.Name == 'Imagen1.jpg') p.IDImagen1__c = att.Id;
                        if (att.Name == 'Imagen2.jpg') p.IDImagen2__c = att.Id;
                        if (att.Name == 'Imagen3.jpg') p.IDImagen3__c = att.Id;
                        if (att.Name == 'Imagen4.jpg') p.IDImagen4__c = att.Id;
                    }
                }
            }
        }

        // Actualizar los productos guardando los IDs y limpiando las URLs
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('TechProductImageDownloaderBatch finalizado con éxito.');
    }

    private Attachment downloadImage(String url, Id parentId, String fileName) {
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setTimeout(60000); // Esperar hasta 60 segundos por imagen
            
            HttpResponse res = h.send(req);
            
            // 200 OK
            if (res.getStatusCode() == 200 && res.getBodyAsBlob() != null) {
                Attachment att = new Attachment();
                att.ParentId = parentId;
                att.Name = fileName;
                att.Body = res.getBodyAsBlob();
                att.ContentType = 'image/jpeg'; // Asumimos un formato estándar
                return att;
            }
        } catch (Exception e) {
            System.debug('Error descargando imagen desde ' + url + ': ' + e.getMessage());
        }
        return null;
    }
}
