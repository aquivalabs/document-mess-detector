public with sharing class SalesforceEinsteinHandler extends CompletionApi {

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
      /* 
        ConnectApi.EinsteinPromptTemplateGenerationsInput request = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        request.promptTextorId = ruleset.context + '\n' + settings.context + '\n\n' + JSON.serialize(prompt);

        ConnectApi.EinsteinLlmAdditionalConfigInput config = defaultConfig();
        config.temperature = 0.4;
        request.additionalConfig = config;

        ConnectApi.EinsteinLLMGenerationItemOutput response = ConnectApi.EinsteinLLM.generateMessages(request).generations[0];
        return (CompletionApi.Results) JSON.deserialize(response.textt, CompletionApi.Results.class); */
        return null;
    }
    

    public override CompletionApi.Rules generateRules(CompletionApi.Ruleset ruleset) {
        /* ConnectApi.EinsteinLlmGenerationsInput request = new ConnectApi.EinsteinLlmGenerationsInput();
        request.promptTextorId = settings.createRulesContext + '\n\n' + 'Name: ' + ruleset.name + '\nDescription: ' + ruleset.description + '\nContext: ' + ruleset.context;

        ConnectApi.EinsteinLlmAdditionalConfigInput config = defaultConfig();
        config.temperature = 1;
        request.additionalConfig = config;

        ConnectApi.EinsteinLLMGenerationItemOutput response = ConnectApi.EinsteinLLM.generateMessages(request).generations[0];
        return (CompletionApi.Rules) JSON.deserialize(response.text, CompletionApi.Rules.class); */
        return null;
    }

    
    @InvocableMethod(/*CapabilityType='FlexTemplate://DmdAnalyseDocument'*/) 
    public static List<Response> populatePromptTemplate(List<Request> requests) {
        List<Response> result = new List<Response>();
        
        CompletionApi.Document document = AnalyseDocument.documentOf( requests[0].analysis );
        CompletionApi.Ruleset ruleset = AnalyseDocument.rulesetOf( requests[0].analysis );
        
        Prompt prompt = new Prompt();
        prompt.document = document.text;
        prompt.rules = ruleset.rules;

        Response output = new Response();
        output.prompt = JSON.serialize(prompt);
        result.add(output);
        
        return result;
    }


    // INNER 

    public class Request {
        @InvocableVariable(required=true)
        public Analysis__c analysis;
    }

    public class Response {
        @InvocableVariable
        public String prompt;
    }

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