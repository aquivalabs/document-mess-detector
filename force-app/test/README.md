- [Ground Rules](#ground-rules)
- [How to use it](#how-to-use-it)

---

# Ground Rules

Good tests look like this

- Clear and concise Setup
- One-line Exercise
- Simple assertions which reflect code and names
- Fit on a single screen
- Isolated, independant.

```java
@IsTest
private class UpdateAccountStatus_Test {

    @IsTest
    private static void toRefreshedOnNewOpportunity() {

        // Setup
        Account acc = (Account) new Account_t()
                            .name('Acme Corp')

                            .add( new Opportunity_t()
                                        .amount(1000)
                                        .closes(2019, 12))
        // Exercise
        .persist();


        // Verify
        System.assertEquals('Refreshed', acc.BillingState);
    }
}
```

1. Don't use shared variables, `@TestSetup` or `static {}` Blocks unless you have to. The make test more coupled which is a bad thing.
1. Don't put the word "test" in the test method name
1. No _ underscores to structure tests. Use separate test classes instead.
1. Use Upper case `@IsTest` and not the outdated `TestMethod` modifier
1. Test class name plus method name should sound a bit like a sentence: Calculator multiplies two integers
1. Don't add words like works, correct, prove that. Everybody knows that this is what tests do.
1. Don't use global variables for tests if you don't need it. It makes tests harder to understand and less independent
1. Don't assert too much in a test. Better make two test methods
1. Every test needs 3 comments to mark its `// Setup`, `// Exercise` and `//Verify` section
1. Move stuff that is needed but somewhat irrelevant to tests to the bottom HELPER section
1. A test class is a better documentation. Start with the general stuff and get more specific at the bottom. Don't add new test at the top but at the bottom.
1. Only use `Test.startTest` `Test.stopTest` when you actually need to either run async code or reset limits. In such cases ALWAYS add a //Note: Explain why I need it

# How to use it

For creating records in Apex Test at Aquiva we use the [rsoesemann/apex-domainbuilder](https://github.com/rsoesemann/apex-domainbuilder) library, as it:

- Encapsulates Object specific logic into simple Domain classes
- Speeds up test by doing DML using Unit-Of-Work
- Enhances readability with a Fluent API style.
- For more read here the [library README](https://github.com/rsoesemann/apex-domainbuilder/blob/master/README.md)

## Add a new Domain class

Each Standard or Custom object that you want to use in a Test setup needs a Domain class like the one below.

1. Call the Class like the object `Student__c` --> `Student`
2. Append `_t` if its a Standard object to not interfere with System class
3. Add only one Constructor to set field defaults
4. Add parametrized constructors for different entry points

```java
@isTest
public class Opportunity_t extends DomainBuilder {

    public Opportunity_t(Account_t a) {
        super(Opportunity.SObjectType);
        setParent(Opportunity.AccountId, a);

        name('Opp1');
        stage('Open');
        closes(System.today().year()+1, 1);
    }

    public Opportunity_t() {
        this(new Account_t());
    }
}
```

## Add Property methods

```java
@isTest
public class Opportunity_t extends DomainBuilder {

    ...

    public Opportunity_t name(String value) {
        return (Opportunity_t) set(Opportunity.Name, value);
    }

    public Opportunity_t amount(Decimal value) {
        return (Opportunity_t) set(Opportunity.Amount, value);
    }

    public Opportunity_t stage(String value) {
        return (Opportunity_t) set(Opportunity.StageName, value);
    }

    public Opportunity_t closes(Integer y, Integer m) {
        return (Opportunity_t) set(Opportunity.CloseDate, Date.newInstance(y, m, 1));
    }
}
```

## Add a new Parent relationship

Parent relationships are added by making them a Constructor Parameter. For cases where in tests the parent is semantically irrelevant but technically needed add a constructor which passes a default Parent.

```java
@isTest
public class Opportunity_t extends DomainBuilder {

    public Opportunity_t(Account_t a) {
        super(Opportunity.SObjectType);
        setParent(Opportunity.AccountId, a);
        ...
    }

    public Opportunity_t() {
        this(new Account_t());
    }

    ...
}
```
## Add a new Child relationship

For test-relevant Child objects add a `add(Child c)` method that delegates the creation and linkage to the appropriate Child Domain class.

```java
@isTest
public class Opportunity_t extends DomainBuilder {

    ...

    public Opportunity_t add(Contact_t c) {
        new OpportunityContactRole_t(this, c);
        return this;
    }
}
```

---

- [Source Code on Github](https://github.com/rsoesemann/apex-domainbuilder)
