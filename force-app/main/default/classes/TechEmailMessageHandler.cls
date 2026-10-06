/**
 * #67: si el asunto de un EmailMessage trae un número de pedido (ej. PE27004),
 * lo relaciona (RelatedToId) con el PedidoDeCompra__c de ese Name.
 * Solo reemplaza RelatedToId vacío, Account u Opportunity; cualquier otro se respeta.
 */
public with sharing class TechEmailMessageHandler {

    private static final Pattern PEDIDO_PATTERN = Pattern.compile('PE[0-9]{5}');

    /**
     * Asigna RelatedToId al pedido cuyo número aparece en el asunto.
     * @param emails Trigger.new de EmailMessage (before insert)
     */
    public static void linkToPedido(List<EmailMessage> emails) {
        List<EmailMessage> matchedEmails = new List<EmailMessage>();
        List<String> pedidoNames = new List<String>();
        for (EmailMessage email : emails) {
            if (String.isBlank(email.Subject) || !isReplaceable(email.RelatedToId)) {
                continue;
            }
            Matcher m = PEDIDO_PATTERN.matcher(email.Subject.toUpperCase());
            if (m.find()) {
                matchedEmails.add(email);
                pedidoNames.add(m.group());
            }
        }
        // Sin acceso a pedidos no se vincula, pero el correo se guarda igual.
        if (matchedEmails.isEmpty() || !Schema.sObjectType.PedidoDeCompra__c.isAccessible()) {
            return;
        }

        Map<String, Id> pedidoIdByName = new Map<String, Id>();
        for (PedidoDeCompra__c pedido : [
            SELECT Id, Name FROM PedidoDeCompra__c WHERE Name IN :pedidoNames
        ]) {
            pedidoIdByName.put(pedido.Name.toUpperCase(), pedido.Id);
        }

        for (Integer i = 0; i < matchedEmails.size(); i++) {
            Id pedidoId = pedidoIdByName.get(pedidoNames[i]);
            if (pedidoId != null) {
                matchedEmails[i].RelatedToId = pedidoId;
            }
        }
    }

    @TestVisible
    private static Boolean isReplaceable(Id relatedToId) {
        if (relatedToId == null) {
            return true;
        }
        Schema.SObjectType relatedType = relatedToId.getSObjectType();
        return relatedType == Account.SObjectType || relatedType == Opportunity.SObjectType;
    }
}
