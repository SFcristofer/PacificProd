/**
 * #67: vincula correos al PedidoDeCompra__c según el número de pedido (PE#####) del asunto.
 */
trigger TechEmailMessageTrigger on EmailMessage (before insert) {
    TechEmailMessageHandler.linkToPedido(Trigger.new);
}
