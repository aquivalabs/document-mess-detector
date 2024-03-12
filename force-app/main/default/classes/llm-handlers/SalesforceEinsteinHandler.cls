public with sharing class SalesforceEinsteinHandler extends CompletionApi {

    // Note: Exposed for easy access by the Setup Step
    public CompletionApi__mdt metadata;
    public CustomSettings settings;
    
    // PUBLIC

    public override void receiveMetadata(CompletionApi__mdt metadata) {
        this.metadata = metadata;
        settings = new CustomSettings(metadata.Settings__c);
    }
    
    public override CompletionApi.Results getCompletion(CompletionApi.Analysis analysis) {
        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.isPreview = false;
        
        ConnectApi.WrappedValue wrapped = new ConnectApi.WrappedValue();
        wrapped.value = new Map<String, String>{ 'id' => analysis.id };
        input.inputParams = new Map<String,ConnectApi.WrappedValue>{ 'Input:analysis' => wrapped };
        
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'DmdAnalyseDocument';
        input.additionalConfig.temperature = 0.5;

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output = null; // TODO ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('DmdAnalyseDocument', input); 
        return (CompletionApi.Results) JSON.deserialize(output.prompt, CompletionApi.Results.class);
    }
    

    public override CompletionApi.Rules generateRules(CompletionApi.Ruleset ruleset) {
        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.isPreview = false;
        
        ConnectApi.WrappedValue wrapped = new ConnectApi.WrappedValue();
        wrapped.value = new Map<String, String>{ 'id' => ruleset.id };
        input.inputParams = new Map<String,ConnectApi.WrappedValue>{ 'Input:ruleset' => wrapped };
        
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'DmdGenerateRuleset';
        input.additionalConfig.temperature = 1;

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output = null; // TODO ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('DmdGenerateRuleset', input); 
        return (CompletionApi.Rules) JSON.deserialize(output.prompt, CompletionApi.Rules.class);
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