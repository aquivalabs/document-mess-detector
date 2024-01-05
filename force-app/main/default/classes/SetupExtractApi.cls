public with sharing class SetupExtractApi extends SetupStep {

    // PUBLIC

    public DmdSettings__c settings { 
        get {
            if(settings == null) {
                DmdSettings__c existing = DmdSettings__c.getOrgDefaults();
                settings = (existing == null) ? new DmdSettings__c(SetupOwnerId=UserInfo.getOrganizationId()) : existing;
            }
            return settings;
        }
        set; 
    }

    public override ApexPages.Message getStatus() {
        if(settings.Id == null || settings.txt_ExtractApiKey__c == null) {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'An <a href="https://extractorapi.com/extractor-api-dashboard/">Extractor API Key</a> is needed to allow text extraction from documents.');
        }
        else {
            String message = 'Your <em><a href="https://extractorapi.com/extractor-api-dashboard/">Extractor API Key</a></em> was successfully stored in a Protected Custom Setting.';
            return new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
        }
    }

    
    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return 'Save';
    }


    // Note: PMD False Positive Setup as Custom Settings only can managed by Admins in Setup page
	@SuppressWarnings('PMD.ApexCRUDViolation')
    public override PageReference run() {
        upsert settings;
        return currentPage();
    }
}