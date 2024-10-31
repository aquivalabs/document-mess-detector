public with sharing class SalesforceModelsApiHandler extends CompletionApi {

    // Note: Exposed for easy access by the Setup Step
    public CompletionApi__mdt metadata;
    public CustomSettings settings;
    
    // PUBLIC

    public override void receiveMetadata(CompletionApi__mdt metadata) {
        this.metadata = metadata;
        settings = new CustomSettings(metadata.Settings__c);
    }
    
    public override CompletionApi.Results getCompletion(CompletionApi.Analysis analysis) {
        aiplatform.ModelsAPI.createChatGenerations_Response response = null;

        CompletionApi.Prompt prompt = new CompletionApi.Prompt();
        prompt.document = analysis.document.text;
        prompt.rules = analysis.ruleset.rules;

        try {
            // https://developer.salesforce.com/docs/einstein/genai/guide/supported-models.html
            response = new Request(settings.model)
                            .system(analysis.ruleset.context + '\n' + settings.context)
                            .user(JSON.serialize(prompt))
                            .send();
        }
        catch(Exception error) {
            throw new ApplicationException('Error while calling OpenAI via Salesforce Trust Layer', error);
        }

        return (CompletionApi.Results) JSON.deserialize(response.Code200.generationDetails.generations[0].content, CompletionApi.Results.class);
    }
    

    public override CompletionApi.Rules generateRules(CompletionApi.Ruleset ruleset) {
        aiplatform.ModelsAPI.createChatGenerations_Response response = null;

        try {
            response = new Request(settings.model)
                            .system(settings.createRulesContext)
                            .user('Name: ' + ruleset.name + '\nDescription: ' + ruleset.description + '\nContext: ' + ruleset.context)
                            .send();
        }
        catch(Exception error) {
            throw new ApplicationException('Error while calling OpenAI via Salesforce Trust Layer', error);
        }

        return (CompletionApi.Rules) JSON.deserialize(response.Code200.generationDetails.generations[0].content, CompletionApi.Rules.class);
    }


    // INNER 

    private class Request {
        private aiplatform.ModelsAPI.createChatGenerations_Request request;

        private Request(String modelName) {
            request = new aiplatform.ModelsAPI.createChatGenerations_Request();
            request.modelName = modelName;
            request.body = new aiplatform.ModelsAPI_ChatGenerationsRequest();
            request.body.messages = new List<aiplatform.ModelsAPI_ChatMessageRequest>();
        }

        private Request system(String content) {
            request.body.messages.add(message(content, 'system'));
            return this;
        }

        private Request user(String content) {
            request.body.messages.add(message(content, 'user'));    
            return this;
        }

        private aiplatform.ModelsAPI_ChatMessageRequest message(String role, String content) {
            aiplatform.ModelsAPI_ChatMessageRequest result = new aiplatform.ModelsAPI_ChatMessageRequest();
            result.role = role;
            result.content = content;
            return result;
        }

        private aiplatform.ModelsAPI.createChatGenerations_Response send() {
            return new aiplatform.ModelsAPI().createChatGenerations(request);
        }
    }
}