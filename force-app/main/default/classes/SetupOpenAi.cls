public with sharing class SetupOpenAi extends SetupStep {

    private OpenAiHandler handler = (OpenAiHandler) CompletionApi.get('OpenAiApi');

    // PUBLIC

    public CompletionApi__mdt metadata { get { return handler.metadata; } private set; }


    public override ApexPages.Message getStatus() {
        if(metadata.ApiKey__c == null ) {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'An OpenAI API Key is needed to enable Insights features.');
        }
        else {
            String message = 'Your Settings were securely stored in a Protected Custom Metadata</a></em>.';
            return new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
        }
    }

    
    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return 'Save';
    }


    public override PageReference run() {
        CompletionApi.persist(metadata);
        
        return currentPage();
    }
}