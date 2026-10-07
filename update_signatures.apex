List<User> usersToUpdate = new List<User>();
for (User u : [SELECT Id, Name, Signature FROM User WHERE Signature LIKE 'http%' AND IsActive = true]) {
    String sig = u.Signature.trim();
    if (sig.contains('servlet.ImageServer') && !sig.startsWith('<img')) {
        System.debug('Actualizando usuario: ' + u.Name);
        u.Signature = '<img src="' + sig + '" alt="Firma" />';
        usersToUpdate.add(u);
    }
}

if (!usersToUpdate.isEmpty()) {
    update usersToUpdate;
    System.debug('SUCCESS_UPDATE_COUNT:' + usersToUpdate.size());
} else {
    System.debug('SUCCESS_UPDATE_COUNT:0');
}
