public with sharing class Notification {

    // Note: Make Custom Notifications testable idea based on https://salesforce.stackexchange.com/a/401150/256
    @TestVisible
    private final static List<Message> MESSAGES = new List<Message>();

    private Message message;
    private List<String> parts = new List<String>();
    private Set<String> userIds = new Set<String>();

    // CTOR

    public Notification() {
        this(UserInfo.getUserId());
    }


    public Notification(Id userId) {
        userIds.add(userId);

        message = new Message();
        message.title = 'Notification';
        message.targetId = '000000000000000AAA';
    }

    // PUBLIC

    public Notification to(Id userId) {
        userIds.add(userId);
        return this;
    }

    public Notification with(Object value) {
        parts.add(String.valueOf(value));
        return this;
    }

    public Notification title(String value) {
        message.title = String.format(value, parts);
        return this;
    }

    public Notification target(Id value) {
        message.targetId = value;
        return this;
    }

    public Notification target(String value) {
        message.targetPageRef = value;
        return this;
    }

    public void send(String bodyText) {
        message.body = String.format(bodyText, parts);

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId( [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'GenericNotification'].Id );
        notification.setTitle(message.title);
        notification.setTargetId(message.targetId);
        notification.setTargetPageRef(message.targetPageRef);
        notification.setBody(message.body);
        notification.send(userIds);

        MESSAGES.add(message);
    }


    // INNER

    @TestVisible
    private class Message {
        @TestVisible String typeId;
        @TestVisible String sender;
        @TestVisible String title;
        @TestVisible String body;
        @TestVisible String targetId;
        @TestVisible String targetPageRef;
    }
}