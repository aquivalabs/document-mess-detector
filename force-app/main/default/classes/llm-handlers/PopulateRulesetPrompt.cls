public with sharing class PopulateRulesetPrompt {

    @InvocableMethod(/*CapabilityType='FlexTemplate://DmdGenerateRuleset'*/) 
    public static List<Response> execute(List<Request> requests) {
        Response result = new Response();
        
        Ruleset__c ruleset = requests[0].ruleset;
        result.prompt = '\nName: ' + ruleset.Name + '\nDescription: ' + ruleset.Description__c + '\nContext: ' + ruleset.Context__c;
        return new List<Response>{ result };
    }

    // INNER

    public class Request {
        @InvocableVariable(required=true)
        public Ruleset__c ruleset;
    }

    public class Response {
        @InvocableVariable
        public String prompt;
    }
}