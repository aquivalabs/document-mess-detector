public with sharing class EinsteinGptHandler extends CompletionApi {

    // Note: Exposed for easy access by the Setup Step
    public CompletionApi__mdt metadata;
    public CustomSettings settings;
    
    // PUBLIC

    public override void receiveMetadata(CompletionApi__mdt metadata) {
        this.metadata = metadata;
        settings = new CustomSettings(metadata.Settings__c);
    }
    
    public override CompletionApi.Results getCompletion(CompletionApi.Document document, CompletionApi.Ruleset ruleset) {
        Prompt prompt = new Prompt();
        prompt.document = document.text;
        prompt.rules = ruleset.rules;
      
        ConnectApi.EinsteinLlmGenerationsInput request = new ConnectApi.EinsteinLlmGenerationsInput();
        request.promptTextorId = ruleset.context + '\n' + settings.context + '\n\n' + JSON.serialize(prompt);

        ConnectApi.EinsteinLlmAdditionalConfigInput config = defaultConfig();
        config.temperature = 0.4;
        request.additionalConfig = config;

        ConnectApi.EinsteinLLMGenerationItemOutput response = ConnectApi.EinsteinLLM.generateMessages(request).generations[0];
        return (CompletionApi.Results) JSON.deserialize(response.text, CompletionApi.Results.class);
    }
    

    public override CompletionApi.Rules generateRules(CompletionApi.Ruleset ruleset) {
        ConnectApi.EinsteinLlmGenerationsInput request = new ConnectApi.EinsteinLlmGenerationsInput();
        request.promptTextorId = settings.createRulesContext + '\n\n' + 'Name: ' + ruleset.name + '\nDescription: ' + ruleset.description + '\nContext: ' + ruleset.context;

        ConnectApi.EinsteinLlmAdditionalConfigInput config = defaultConfig();
        config.temperature = 1;
        request.additionalConfig = config;

        ConnectApi.EinsteinLLMGenerationItemOutput response = ConnectApi.EinsteinLLM.generateMessages(request).generations[0];
        return (CompletionApi.Rules) JSON.deserialize(response.text, CompletionApi.Rules.class);
    }


    // PRIVATE 

    private ConnectApi.EinsteinLlmAdditionalConfigInput defaultConfig() {
        ConnectApi.EinsteinLlmAdditionalConfigInput result = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        result.applicationName = 'ISV-PILOT-DF23-CTS5978453120';
        result.temperature = 1;
        result.maxTokens = 1000;
        result.model = settings.model;
        return result;
    }

        
    // INNER

    public class CustomSettings {
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

    public class Prompt {
        public String document;
        public List<CompletionApi.Rule> rules;
    }
}