public with sharing class Llama2Handler extends CompletionApi {
  // Note: Exposed for easy access by the Setup Step
  public CompletionApi__mdt metadata;
  public CustomSettings settings;

  @TestVisible
  private Request apiRequest = new Request();

  // PUBLIC

  public override void receiveMetadata(CompletionApi__mdt metadata) {
    this.metadata = metadata;
    settings = new CustomSettings(metadata.Settings__c);

    apiRequest.parameters = new Parameters(
      settings.maxNewTokens,
      settings.temperature
    );
  }

  public override CompletionApi.Results getCompletion(
    CompletionApi.Document document,
    CompletionApi.Ruleset ruleset
  ) {
    List<Input> inputs = new List<Input>{
      new Input('system', systemMessage(ruleset)),
      new Input('user', userMessage(document, ruleset))
    };
    apiRequest.inputs.add(inputs);

    HttpResponse response = null;
    try {
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:Llama2AI');
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json');
      request.setHeader(
        'X-Amzn-SageMaker-Custom-Attributes',
        'accept_eula=true'
      );
      request.setTimeout(120000);
      request.setBody(apiRequest.asJson());
      response = new Http().send(request);
      if (response.getStatusCode() != 200) {
        throw new ApplicationException(
          'Error: ' + response.getStatus() + ': ' + apiRequest.asJson()
        );
      }
    } catch (Exception ex) {
      throw new ApplicationException(
        'Error: ' + ex.getMessage() + ': ' + apiRequest.asJson()
      );
    }
    return convert(response);
  }

  // PRIVATE

  private CompletionApi.Results convert(HttpResponse rawResponse) {
    List<Response> llamaAiResponse = (List<Response>) JSON.deserialize(
      rawResponse.getBody(),
      List<Response>.class
    );
    // It's not possible to deserialize string into external package's object
    Results result = (Results) JSON.deserialize(
      llamaAiResponse[0].jsonAnswer(),
      Results.class
    );

    CompletionApi.Results convertedResults = new CompletionApi.Results();
    convertedResults.results = new List<CompletionApi.Result>();
    for (Result singleResult : result.results) {
      CompletionApi.Result convertedResult = new CompletionApi.Result();
      convertedResult.ruleId = singleResult.ruleId;
      convertedResult.status = singleResult.status;
      convertedResult.justification = singleResult.justification;

      convertedResults.results.add(convertedResult);
    }

    return convertedResults;
  }

  private String systemMessage(CompletionApi.Ruleset ruleset) {
    return ruleset.context + '\n' + settings.context;
  }

  private String userMessage(
    CompletionApi.Document document,
    CompletionApi.Ruleset ruleset
  ) {
    Prompt prompt = new Prompt(ruleset.rules);
    prompt.document = document.text;

    return 'Rules to check:\n' + JSON.serialize(prompt);
  }

  // INNER

  public class CustomSettings {
    public String context;
    public Integer maxNewTokens;
    public Decimal temperature;

    public CustomSettings(String jsonString) {
      Map<String, Object> untyped = (Map<String, Object>) JSON.deserializeUntyped(
        jsonString
      );

      context = (String) untyped.get('context');
      maxNewTokens = (Integer) untyped.get('maxNewTokens');
      temperature = (Decimal) untyped.get('temperature');
    }
  }

  public class Request {
    public List<List<Input>> inputs = new List<List<Input>>();
    public Parameters parameters;
    public String asJson() {
      return JSON.serialize(this, true);
    }
  }

  public class Input {
    public String role;
    public String content;

    public Input(String role, String content) {
      this.role = role;
      this.content = content;
    }
  }

  public class Parameters {
    public Integer max_new_tokens;
    public Decimal top_p = 0.9;
    public Decimal temperature;

    public Parameters(Integer maxNewTokens, Decimal temperature) {
      this.max_new_tokens = maxNewTokens;
      this.temperature = temperature;
    }
  }

  public class Prompt {
    public String document;
    public List<Rule> rules = new List<Rule>();

    // It's not possible to serialize an object if it has references to objects from external package
    public Prompt(List<CompletionApi.Rule> dmdRules) {
      for (CompletionApi.Rule rule : dmdRules) {
        this.rules.add(new Rule(rule));
      }
    }
  }

  public class Rule {
    public String ruleId;
    public String content;

    public Rule(CompletionApi.Rule rule) {
      this.ruleId = rule.ruleId;
      this.content = rule.content;
    }
  }

  public class Response {
    public Generation generation;

    public String jsonAnswer() {
      if (generation == null || generation.content == null) {
        throw new ApplicationException(
          'No message provided in generated response.'
        );
      }

      return '{' +
        generation.content.substringAfter('{')
          .substringBeforeLast('}')
          .replace('\\"', '"')
          .replace('\\n', '') +
        '}';
    }
  }

  public class Generation {
    public String role;
    public String content;
  }

  public class Results {
    public List<Result> results = new List<Result>();
  }

  public class Result {
    public String ruleId;
    public String status;
    public String justification;
  }

  public class ApplicationException extends Exception {
  }
}
