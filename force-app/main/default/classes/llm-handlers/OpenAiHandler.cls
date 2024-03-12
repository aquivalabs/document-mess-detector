// Note: Allow underscores in REST resource properties
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class OpenAiHandler extends CompletionApi {

    // Note: Exposed for easy access by the Setup Step
    public CompletionApi__mdt metadata;
    public CustomSettings settings;
    
    // PUBLIC

    public override void receiveMetadata(CompletionApi__mdt metadata) {
        this.metadata = metadata;
        settings = new CustomSettings(metadata.Settings__c);
    }
    
    public override CompletionApi.Results getCompletion(CompletionApi.Analysis analysis) {
        CompletionApi.Prompt prompt = new CompletionApi.Prompt();
        prompt.document = analysis.document.text;
        prompt.rules = analysis.ruleset.rules;

        Request request = new Request();
        request.model = settings.model;
        request.systemMessage(analysis.ruleset.context + '\n' + settings.context);
        request.userMessage(JSON.serialize(prompt));
      
        Response response = complete(request);
        return (CompletionApi.Results) JSON.deserialize(response.bestAnswer(), CompletionApi.Results.class);
    }
    

    public override CompletionApi.Rules generateRules(CompletionApi.Ruleset ruleset) {
        Request request = new Request();
        request.model = settings.model;
        request.temperature = 0.5;
        request.systemMessage(settings.createRulesContext);
        request.userMessage('Name: ' + ruleset.name + '\nDescription: ' + ruleset.description + '\nContext: ' + ruleset.context);

        Response response = complete(request);
        return (CompletionApi.Rules) JSON.deserialize(response.bestAnswer(), CompletionApi.Rules.class);
    }


    // Note: PMD Ignore see https://salesforce.stackexchange.com/q/406970/256
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public Response complete(Request request) {
        HttpResponse result = null;

        try {
            HttpRequest callout = new HttpRequest();
            callout.setEndpoint('https://api.openai.com/v1/chat/completions');
            callout.setMethod('POST');
            callout.setHeader('Content-Type', 'application/json');
            callout.setHeader('Authorization', 'Bearer ' + metadata.ApiKey__c);
            callout.setTimeout(120000);
            callout.setBody(request.asJson());

            result = new Http().send(callout);
            if(result.getStatusCode() != 200) {
                throw new ApplicationException('HTTP Response: ' + result.getStatusCode() + ' - ' + result.getStatus());
            }
        } 
        catch(Exception error) {
            throw new ApplicationException('Error while calling OpenAI', error);
        }

        return (Response) JSON.deserialize(result.getBody(), Response.class);
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

    public class Request {
        public List<Message> messages = new List<Message>();
        public Decimal temperature = 0.0;
        private String model;
        private ResponseFormat response_format = new ResponseFormat();  
    
        public String asJson() {
            return JSON.serialize(this, true);
        } 
    
        public void systemMessage(String message) {
            messages.add(new Message('system', message));
        }
    
        public void userMessage(String message) {
            messages.add(new Message('user', message));
        }
    }
    
    public class Message {
        public String role;
        public String content;

        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
    }

    public class Response {
        private String id;
        private Integer created;
        private String model;
        private Usage usage;
        private List<Choice> choices = new List<Choice>();

        @TestVisible
        private Response withChoice(Message message) {
            Choice choice = new Choice();
            choice.message = message;
            choices.add(choice);
            return this;
        }
    
        public String bestAnswer() {
            if(choices == null || choices.isEmpty()) {
                throw new ApplicationException('No message provided in generated response.');
            }
    
            return choices[0].message.content;
        }
    }
    
    public class Usage {
        private Integer prompt_tokens;
        private Integer completion_tokens;
        private Integer total_tokens;
    }

    public class Choice {
        private String finish_reason;
        private Integer index;
        private Message message;
    }

    public class ResponseFormat {
        public String type = 'json_object';
    }
}