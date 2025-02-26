public with sharing abstract class CompletionApi {

    private static final Set<String> IGNORED_MD_FIELDS = new Set<String>{ 'DeveloperName', 'Id', 'Label', 'Language', 'MasterLabel', 'NamespacePrefix', 'QualifiedApiName', 'DeveloperName' };
                    
    @TestVisible
    private static List<CompletionApi__mdt> mocks = new List<CompletionApi__mdt>();


    // ABSTRACT
    
    public abstract void receiveMetadata(CompletionApi__mdt metadata);
    public abstract Results getCompletion(Analysis analysis);

    // VIRTUAL 
    // To not break exisiting handlers just virtual (see https://salesforce.stackexchange.com/a/410879/256)
    public virtual Rules generateRules(Ruleset ruleset) {
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
        // Note: Prefer Qualified names but also accept namespace-less. See https://salesforce.stackexchange.com/questions/169815/disjunctions-not-supported
        List<CompletionApi__mdt> result = [SELECT MasterLabel, Label, QualifiedApiName, DeveloperName, ApiKey__c, HandlerClass__c, Settings__c
                                           FROM CompletionApi__mdt WHERE QualifiedApiName = :apiName WITH SYSTEM_MODE];
        result.addAll([SELECT MasterLabel, Label, QualifiedApiName, DeveloperName, ApiKey__c, HandlerClass__c, Settings__c
                        FROM CompletionApi__mdt WHERE DeveloperName = :apiName WITH SYSTEM_MODE]);                                  
        return (useMocks()) ? mocks[0] : result[0];
    }

    private static Boolean useMocks() {
        return (Test.isRunningTest() && !mocks.isEmpty());
    }

    // INNER

    public class Analysis {
        public String id;        
        public Document document;
        public Ruleset ruleset;
    }

    public class Document {
        public String text;        
    }

    public class Ruleset {
        public String id;
        public String name;
        public String description;
        public String context;
        public List<Rule> rules = new List<Rule>();
    }

    public class Rule {
        public String ruleId;
        public String name;
        public String description;
        public String content;
    }

    public class Rules {
        public List<Rule> rules = new List<Rule>();
    }

    public class Results {
        public List<Result> results = new List<Result>();
    }

    public class Result {
        public String ruleId;
        public String status;
        public String justification;
    }

    public class Prompt {
        public String document;
        public List<CompletionApi.Rule> rules;
    }

    public class DeployCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            // TODO Reload Setup page via Event?
        }
    }

    public class ApplicationException extends Exception {
        public override String getStackTraceString() {
            String result = '';
    
            Exception ex = this;
            do {
                result += ex.getTypeName() + ': ' +  ex.getMessage() + ': ';
                result += (ex == this) ? getCauseStackTrace() : ex.getStackTraceString();
                ex = ex.getCause();
                if(ex != null) {
                    result += '\n';
                }
            } 
            while(ex != null);
    
            return result;
        }
    
        private String getCauseStackTrace() {
            return (super.getCause() == null ) ? '' : super.getCause().getStackTraceString();
        }
    }
}