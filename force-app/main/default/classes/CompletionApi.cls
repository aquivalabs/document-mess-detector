// Note: API for outside classes to extend DMD must remain global
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing abstract class CompletionApi {

    private static final Set<String> IGNORED_MD_FIELDS = new Set<String>{ 'DeveloperName', 'Id', 'Label', 'Language', 'MasterLabel', 'NamespacePrefix', 'QualifiedApiName', 'DeveloperName' };
                    
    @TestVisible
    private static List<CompletionApi__mdt> mocks = new List<CompletionApi__mdt>();


    // ABSTRACT
    
    global abstract void receiveMetadata(CompletionApi__mdt metadata);
    global abstract Results getCompletion(Document document, Ruleset ruleset);

    // VIRTUAL 
    // To not break exisiting handlers just virtual (see https://salesforce.stackexchange.com/a/410879/256)
    global virtual Rules generateRules(Ruleset ruleset) {
        throw new ApplicationException('generateRules() method not implemented by the current CompletionApi class.');
    }
    
    // PUBLIC

    public static CompletionApi get(String apiName) {
        return initHandler( queryByName(apiName) );
    }

    public static List<CompletionApi> getAll() {
        List<CompletionApi> result = new List<CompletionApi>();
       
        for(CompletionApi__mdt cmdt : queryAll()) {
            result.add( initHandler(cmdt) );
        }

        return result;
    }

    public static void persist(CompletionApi__mdt record) {
        String prefix = record.getSObjectType().getDescribe().getName().replace('__mdt', '');

        Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();
        cmd.fullName = prefix + '.' + record.QualifiedApiName;
        cmd.label = record.MasterLabel;

        for (String field : record.getPopulatedFieldsAsMap().keySet()) {
            if(!IGNORED_MD_FIELDS.contains(field)) {
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = field;
                customField.value = record.get(field);

                cmd.values.add(customField);
            }
        }

        Metadata.DeployContainer container = new Metadata.DeployContainer();
        container.addMetadata(cmd);

        Metadata.Operations.enqueueDeployment(container, new DeployCallback());
    }

    // PRIVATE

    private static CompletionApi initHandler(CompletionApi__mdt cmdt) {
        CompletionApi result = null;

        try {
            String noNamespace = null;
            result = (CompletionApi) Type.forName(noNamespace, cmdt.HandlerClass__c).newInstance();
            result.receiveMetadata(cmdt);
        }
        catch(Exception error) {
            throw new ApplicationException('Could not init Completion Api Handler: ', error);
        }
        
        return result;
    }

    @TestVisible
    private static List<CompletionApi__mdt> queryAll() {
        return (useMocks()) ? mocks
                            : [SELECT MasterLabel, Label, QualifiedApiName, DeveloperName, ApiKey__c, HandlerClass__c, Settings__c
                                FROM CompletionApi__mdt WITH SYSTEM_MODE];
    }
    
    @TestVisible
    private static CompletionApi__mdt queryByName(String apiName) {
        return (useMocks()) ? mocks[0] 
                            : [SELECT MasterLabel, Label, QualifiedApiName, DeveloperName, ApiKey__c, HandlerClass__c, Settings__c
                                FROM CompletionApi__mdt WHERE QualifiedApiName = :apiName WITH SYSTEM_MODE];
    }

    private static Boolean useMocks() {
        return (Test.isRunningTest() && !mocks.isEmpty());
    }

    // INNER

    global class Document {
        global String text;        
    }

    global class Ruleset {
        global String name;
        global String description;
        global String context;
        global List<Rule> rules = new List<Rule>();
    }

    global class Rule {
        global String ruleId;
        global String name;
        global String description;
        global String content;
    }

    global class Rules {
        global List<Rule> rules = new List<Rule>();
    }

    global class Results {
        global List<Result> results = new List<Result>();
    }

    global class Result {
        global String ruleId;
        global String status;
        global String justification;
    }

    public class DeployCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            // TODO Reload Setup page via Event?
        }
    }
}