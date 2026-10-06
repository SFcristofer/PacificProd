@IsTest
private class TechEmailMessageHandlerTest {

    /**
     * Crea el pedido PE99001. Va dentro de startTest/stopTest (límites frescos) porque
     * initProformaTest + el proceso "Pedido: Nuevo pedido" agotan los límites del contexto.
     */
    private static Id createPedido() {
        TestUtil tu = new TestUtil();
        tu.initProformaTest();
        Test.startTest();
        PedidoDeCompra__c pedido = tu.createPedidoDeCompraStatus('Embarcado');
        pedido.Name = 'PE99001';
        update pedido;
        Test.stopTest();
        return pedido.Id;
    }

    private static EmailMessage newEmail(String subject, Id relatedToId) {
        return new EmailMessage(Subject = subject, RelatedToId = relatedToId, Status = '3',
                                FromAddress = 'test@test.com', TextBody = 'x');
    }

    private static Id relatedOf(EmailMessage email) {
        return [SELECT RelatedToId FROM EmailMessage WHERE Id = :email.Id].RelatedToId;
    }

    @IsTest
    static void linksWhenRelatedToIsEmpty() {
        Id pedidoId = createPedido();
        EmailMessage email = newEmail('RE: Embarque pe99001 confirmado', null);
        insert email;
        Assert.areEqual(pedidoId, relatedOf(email));
    }

    @IsTest
    static void replacesAccount() {
        Id pedidoId = createPedido();
        Account acc = new Account(Name = 'tech test acc');
        insert acc;
        EmailMessage email = newEmail('Pedido PE99001', acc.Id);
        insert email;
        Assert.areEqual(pedidoId, relatedOf(email));
    }

    @IsTest
    static void keepsOtherRelatedTo() {
        Assert.isFalse(TechEmailMessageHandler.isReplaceable(createPedido()));
    }

    @IsTest
    static void ignoresUnknownOrMissingNumber() {
        createPedido();
        EmailMessage unknown = newEmail('Pedido PE12345', null);
        EmailMessage noNumber = newEmail('Hola', null);
        insert new List<EmailMessage>{ unknown, noNumber };
        Assert.isNull(relatedOf(unknown));
        Assert.isNull(relatedOf(noNumber));
    }

    @IsTest
    static void bulkInsert() {
        Id pedidoId = createPedido();
        List<EmailMessage> emails = new List<EmailMessage>();
        for (Integer i = 0; i < 200; i++) {
            emails.add(newEmail('Pedido PE99001 #' + i, null));
        }
        insert emails;
        Assert.areEqual(200, [SELECT COUNT() FROM EmailMessage WHERE RelatedToId = :pedidoId]);
    }
}
