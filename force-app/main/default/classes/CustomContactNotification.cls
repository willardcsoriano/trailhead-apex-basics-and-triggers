public with sharing class CustomContactNotification {
    // Public method
    public static void notifyUsers(Set<String> recipientsIds, Integer recordCount) {
        // Get the ID for the custom notification type created in Setup
 		CustomNotificationType notificationType =
            [SELECT Id, DeveloperName
             FROM CustomNotificationType
             WHERE DeveloperName='New_Contact_Notification'
             WITH USER_MODE];
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        // Set the contents for the notification
        notification.setTitle('Trailhead Trigger Tutorial');
        notification.setBody(recordCount + ' contact(s) were inserted.');
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        // '000000000000000AAA' is a dummy targetId value
        notification.setTargetId('000000000000000AAA');
       // Send the notification
       try {
           notification.send(recipientsIds);
           System.debug('Custom notification sent successfully.');
       }
       catch (Exception e) {
           System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}