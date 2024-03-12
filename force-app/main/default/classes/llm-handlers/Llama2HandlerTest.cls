@IsTest
private class Llama2HandlerTest {
  @IsTest
  static void getCompletion() {


    CompletionApi.Document doc = new CompletionApi.Document();
    doc.text = 'any';

    CompletionApi.Rule rule = new CompletionApi.Rule();
    rule.content = 'any';
    rule.ruleId = 'any';

    CompletionApi.Ruleset ruleset = new CompletionApi.Ruleset();
    ruleset.context = 'any';
    ruleset.rules = new List<CompletionApi.Rule>{ rule };

    CompletionApi.Analysis analysis = new CompletionApi.Analysis();
    analysis.document = doc;
    analysis.ruleset = ruleset;

    CompletionApi__mdt llamaConfig = [
      SELECT
        MasterLabel,
        Label,
        QualifiedApiName,
        DeveloperName,
        ApiKey__c,
        HandlerClass__c,
        Settings__c
      FROM CompletionApi__mdt
      WHERE DeveloperName = 'Llama2'
    ];

    Test.setMock(HttpCalloutMock.class, new Llama2HttpMock());
    Llama2Handler handler = new Llama2Handler();
    handler.receiveMetadata(llamaConfig);

    Test.startTest();
    CompletionApi.Results results = handler.getCompletion(analysis);
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.isTrue(results.results.size() > 0);
  }

  // HELPER

  public class Llama2HttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
      '[\n' +
      '    {\n' +
      '        "generation": {\n' +
      '            "role": "assistant",\n' +
      '            "content": "Result: {\\n\\"results\\": [\\n{\\n\\"ruleId\\": \\"a057a00000FC8TNAA1\\",\\n\\"status\\": \\"Success\\",\\n\\"justification\\": \\"The document does not contain any spelling or grammar errors.\\"\\n}]} Some text here."\n' +
      '        }\n' +
      '    }\n' +
      ']'
      );
      res.setStatusCode(200);
      return res;
    }
  }
}
