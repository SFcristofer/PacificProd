// Script para sincronizar retroactivamente la información del proveedor
// desde los Productos de Fábrica ("Primary") hacia sus Productos Base históricos.
// Esto replica la lógica del flujo Tech_Sync_Fabrica_Primaria_a_Base para registros antiguos.

List<Product2> factoryProds = [
    SELECT Id, Fabrica__c, Codigo_Proveedor__c, ProductoBase__c 
    FROM Product2 
    WHERE Estatus__c = 'Primary' 
    AND ProductoBase__r.ProductCode = 'H309128S'
];

Map<Id, Product2> baseProductsToUpdate = new Map<Id, Product2>();

for (Product2 fp : factoryProds) {
    // Agregamos al mapa para asegurar que solo haya una actualización por Producto Base
    baseProductsToUpdate.put(fp.ProductoBase__c, new Product2(
        Id = fp.ProductoBase__c,
        Fabrica__c = fp.Fabrica__c,
        Codigo_Proveedor__c = fp.Codigo_Proveedor__c
    ));
}

System.debug('Productos Base a actualizar: ' + baseProductsToUpdate.size());

if (!baseProductsToUpdate.isEmpty()) {
    // Usamos false para que si un registro falla, los demás se actualicen correctamente
    Database.SaveResult[] results = Database.update(baseProductsToUpdate.values(), false);
    
    Integer exito = 0;
    Integer errores = 0;
    
    for (Integer i = 0; i < results.size(); i++) {
        if (results[i].isSuccess()) {
            exito++;
        } else {
            errores++;
            System.debug('Error en ID ' + baseProductsToUpdate.values()[i].Id + ': ' + results[i].getErrors()[0].getMessage());
        }
    }
    
    System.debug('Actualizaciones exitosas: ' + exito);
    System.debug('Errores: ' + errores);
} else {
    System.debug('No hay registros antiguos para sincronizar.');
}
