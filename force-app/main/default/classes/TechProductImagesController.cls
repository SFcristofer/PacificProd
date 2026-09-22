public with sharing class TechProductImagesController {

    @AuraEnabled
    public static void saveImages(Id recordId, String onedriveLink, String img1, String img2, String img3, String img4) {
        try {
            Product2 prod = new Product2(Id = recordId);
            if (onedriveLink != null) {
                if (onedriveLink.length() > 255) {
                    throw new AuraHandledException('El enlace de OneDrive es demasiado largo (máximo 255 caracteres). Por favor, utiliza un enlace más corto o un acortador de URLs.');
                }
                prod.Tech_Enlace_OneDrive__c = onedriveLink;
            }
            
            // Mantenemos la lógica antigua por retrocompatibilidad si otros componentes la usaban,
            // pero el LWC ahora usará saveSingleImage para evitar el límite de heap size.
            if (img1 != null && img1.length() > 0) prod.IDImagen1__c = saveAttachment(recordId, 'Imagen1.jpg', img1);
            if (img2 != null && img2.length() > 0) prod.IDImagen2__c = saveAttachment(recordId, 'Imagen2.jpg', img2);
            if (img3 != null && img3.length() > 0) prod.IDImagen3__c = saveAttachment(recordId, 'Imagen3.jpg', img3);
            if (img4 != null && img4.length() > 0) prod.IDImagen4__c = saveAttachment(recordId, 'Imagen4.jpg', img4);
            
            update prod;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage() + ' (Línea: ' + e.getLineNumber() + ')');
            throw ahe;
        }
    }

    @AuraEnabled
    public static void saveSingleImage(Id recordId, Integer imageIndex, String base64Data) {
        try {
            if (String.isBlank(base64Data)) return;

            if (base64Data.contains(',')) {
                base64Data = base64Data.substringAfter(',');
            }
            Blob fileBody = EncodingUtil.base64Decode(base64Data);

            AWS_Generacion_Cotizacion__mdt aws_mdt = [SELECT Id, AWS_S3_Bucket_Name__c, AWS_Secret__c, AWS_Key__c, AWS_S3_Host__c, AWS_S3_Images__c, Salesforce_Images_DirId__c, Size_Image__c FROM AWS_Generacion_Cotizacion__mdt WHERE MasterLabel = 'AWSCotizacion' LIMIT 1];
            Integer SIZE_IMAGE = Integer.valueOf(aws_mdt.Size_Image__c);

            if (fileBody.size() > SIZE_IMAGE) {
                throw new AuraHandledException('La imagen tiene un tamaño mayor a [' + SIZE_IMAGE + '] bytes.');
            }

            Product2 prod = [SELECT Id, ProductCode FROM Product2 WHERE Id = :recordId LIMIT 1];
            String suffix = (imageIndex == 1) ? '' : '_' + String.valueOf(imageIndex);
            String imageName = prod.ProductCode + suffix;

            // Importante: La llamada (callout) debe hacerse ANTES de insertar el Document (operación DML)
            if (imageIndex == 1 && aws_mdt != null) {
                if (imageName != null && imageName.length() > 7) {
                    String nameImageToUpload = imageName.substring(0, 7);
                    FileAWSS3Uploader.uploadImage(aws_mdt.AWS_Key__c, aws_mdt.AWS_Secret__c, aws_mdt.AWS_S3_Bucket_Name__c, aws_mdt.AWS_S3_Host__c, nameImageToUpload, aws_mdt.AWS_S3_Images__c, fileBody);
                }
            }

            Document doc = new Document();
            doc.Name = imageName;
            doc.Body = fileBody;
            doc.FolderId = aws_mdt.Salesforce_Images_DirId__c;
            doc.ContentType = 'image/jpeg';
            insert doc;

            Product2 prodToUpdate = new Product2(Id = recordId);
            if (imageIndex == 1) prodToUpdate.IdImagen1__c = doc.Id;
            if (imageIndex == 2) prodToUpdate.IdImagen2__c = doc.Id;
            if (imageIndex == 3) prodToUpdate.IdImagen3__c = doc.Id;
            if (imageIndex == 4) prodToUpdate.IdImagen4__c = doc.Id;
            update prodToUpdate;

        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage() + ' (Línea: ' + e.getLineNumber() + ')');
            throw ahe;
        }
    }

    private static Id saveAttachment(Id parentId, String name, String base64Data) {
        if (base64Data.contains(',')) {
            base64Data = base64Data.substringAfter(',');
        }
        Attachment att = new Attachment();
        att.ParentId = parentId;
        att.Name = name;
        att.Body = EncodingUtil.base64Decode(base64Data);
        att.ContentType = 'image/jpeg';
        insert att;
        return att.Id;
    }
}