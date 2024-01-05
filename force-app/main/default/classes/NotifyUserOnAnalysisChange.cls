public with sharing class NotifyUserOnAnalysisChange implements Triggers.Handler, Triggers.AfterUpdate {
    // PUBLIC 

    public Boolean criteria(Triggers.Context ctx) {
        return ctx.props.isChanged(Analysis__c.Status__c);
    }

    public void afterUpdate(Triggers.Context ctx) {
        for(Analysis__c analysis : [SELECT Status__c, OwnerId, Ruleset__r.Name, DocumentName__c, Failed__c, FailReason__c, 
                                           (SELECT Rule__r.Name FROM Results__r WHERE Status__c <> 'Success') 
                                    FROM Analysis__c 
                                    WHERE Id IN :ctx.props.newMap.keySet() 
                                    AND IsRegression__c = FALSE 
                                    WITH SYSTEM_MODE]) {

            Notification message = new Notification(analysis.OwnerId)
                                            .target(analysis.Id)
                                            .with(analysis.DocumentName__c)
                                            .with(analysis.Ruleset__r.Name);

            if(analysis.Status__c == 'Successful') {
                message.title('"{0}" passed DMD analysis')
                        .send('All rules from "{1}" are fullfilled.\n\nClick for details.');
            }
            else if(analysis.Status__c == 'Failed') {
                message.title('"{0}" failed DMD analysis')
                        .with(issues(analysis))
                        .send('Issues (from "{1}"):{2}\n\nClick for details.');
            }
            else if(analysis.Status__c == 'Error') {
                message.title('DMD analysis aborted with error')
                        .with(analysis.FailReason__c.abbreviate(750))
                        .send('{2}\n\nClick for details.');
            }
        }
    }

    // PRIVATE

    private String issues(Analysis__c analysis) {
        String result = '';

        for(Result__c issue : analysis.Results__r) {
            result += '\n- ' + issue.Rule__r.Name;
        }

        return result;
    }
}