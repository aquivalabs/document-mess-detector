public with sharing class PopulateAnalysisPrompt {

    @InvocableMethod(/*CapabilityType='FlexTemplate://DmdAnalyseDocument'*/) 
    public static List<Response> execute(List<Request> requests) {
        CompletionApi.Analysis analysis = AnalyseDocument.toGenericStructure( requests[0].analysis );
        
        CompletionApi.Prompt prompt = new CompletionApi.Prompt();
        prompt.document = analysis.document.text;
        prompt.rules = analysis.ruleset.rules;

        Response result = new Response();
        result.prompt = JSON.serialize(prompt);
        return new List<Response>{ result };
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
}