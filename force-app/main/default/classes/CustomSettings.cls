public with sharing class CustomSettings {
    public String model;
    public String context;
    public String createRulesContext;

    public CustomSettings(String jsonString) {
        Map<String, Object> untyped = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        model = (String) untyped.get('model');
        context = (String) untyped.get('context');
        createRulesContext = (String) untyped.get('createRulesContext');
    }
}