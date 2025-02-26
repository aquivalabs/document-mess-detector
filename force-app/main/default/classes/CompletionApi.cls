public with sharing abstract class CompletionApi {

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
}