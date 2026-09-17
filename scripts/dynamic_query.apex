String query = 'SELECT Costos_Extra__c, Gastos_Bancarios__c, cal_Costo_Financiero_Deposito_Fabrica__c, cal_Costo_Financiero_Financiacion_Client__c FROM EscandalloLineItem__c WHERE Id = \'a0A4w00000no8S5EAI\' LIMIT 1';
SObject item = Database.query(query);
System.debug('--- DYNAMIC QUERY RESULTS ---');
System.debug('Costos_Extra__c: ' + item.get('Costos_Extra__c'));
System.debug('Gastos_Bancarios__c: ' + item.get('Gastos_Bancarios__c'));
System.debug('cal_Costo_Financiero_Deposito_Fabrica__c: ' + item.get('cal_Costo_Financiero_Deposito_Fabrica__c'));
System.debug('cal_Costo_Financiero_Financiacion_Client__c: ' + item.get('cal_Costo_Financiero_Financiacion_Client__c'));
