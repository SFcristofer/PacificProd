Id userId1 = '0054w00000AY1qjAAD';
Id userId2 = '005VT00000O4r6LYAR';
List<Id> userIds = new List<Id>{userId1, userId2};

for (Id uId : userIds) {
    try { 
        System.UserManagement.deregisterVerificationMethod(uId, Auth.VerificationMethod.U2F); 
    } catch (Exception e) {}

    try { 
        System.UserManagement.deregisterVerificationMethod(uId, Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR); 
    } catch (Exception e) {}

    try { 
        System.UserManagement.deregisterVerificationMethod(uId, Auth.VerificationMethod.TOTP); 
    } catch (Exception e) {}
}
System.debug('MFA desvinculado para ambos usuarios de soporte.');
