-   [How-to Trigger](#how-to-trigger)
-   [How to use it](#how-to-use-it)

---

# How-to Trigger

One of the best practices when working with Apex triggers is the trigger handler pattern.
Business logic should be separated from the triggers themselves.

```java
trigger AccountTrigger on Account (before update, after update) {
    Triggers.prepare()
        .beforeUpdate()
            .bind(new MyAccountHandler())
            .bind(new AnotherAccountHandler())
        .afterUpdate()
            .bind(new AnotherAccountHandler())
            .bind(new MyAccountHandler())
        .execute();
}
```

# How to use it

## Create Handler class

1. Add `Triggers.Handler` interface
2. Specify handler context with the following interfaces:
    - `Triggers.BeforeInsert`
    - `Triggers.AfterInsert`
    - `Triggers.BeforeUpdate`
    - `Triggers.AfterUpdate`
    - `Triggers.BeforeDelete`
    - `Triggers.AfterDelete`
    - `Triggers.AfterUndelete`
3. Use `Trigger.Context` to get all necessary details e.g `context.props.newList`

    | Property      | Type               | Description              |
    | ------------- | ------------------ | ------------------------ |
    | sObjectType   | SObjectType        | The current SObjectType. |
    | isExecuting   | Boolean            | Trigger.isExecuting      |
    | isBefore      | Boolean            | Trigger.isBefore         |
    | isAfter       | Boolean            | Trigger.isAfter          |
    | isInsert      | Boolean            | Trigger.isInsert         |
    | isUpdate      | Boolean            | Trigger.isUpdate         |
    | isDelete      | Boolean            | Trigger.isDelete         |
    | isUndelete    | Boolean            | Trigger.isUndelete       |
    | oldList       | List\<SObject\>    | Trigger.old              |
    | oldMap        | Map\<Id, SObject\> | Trigger.oldMap           |
    | newList       | List\<SObject\>    | Trigger.new              |
    | newMap        | Map\<Id, SObject\> | Trigger.newMap           |
    | operationType | TriggerOperation   | Trigger.operationType    |
    | size          | Integer            | Trigger.size             |

```java
public class MyAccountHandler implements
    Triggers.Handler, Triggers.BeforeUpdate, Triggers.AfterUpdate {

    public Boolean criteria(Triggers.Context context) {
        return Triggers.WHEN_ALWAYS;
        // There are also helper methods to check if certain fields have changes
        // return context.props.isChanged(Account.Name);
        // return context.props.isChangedAny(Account.Name, Account.Description);
        // return context.props.isChangedAll(Account.Name, Account.Description);
    }

    public void beforeUpdate(Triggers.Context context) {
        // System.debug(context.props.newList);
    }

    public void afterUpdate(Triggers.Context context) {
        // System.debug(context.props.newMap);
    }
}
```

## Add Handler to the Trigger

1. Keep one trigger per object
2. Use the `bind` method to pass your handler

```java
trigger AccountTrigger on Account (before update, after update) {
    Triggers.prepare()
        .beforeUpdate()
            .bind(new MyAccountHandler())
            .bind(new AnotherAccountHandler())
        .afterUpdate()
            .bind(new AnotherAccountHandler())
            .bind(new MyAccountHandler())
        .execute();
}
```

---

-   [Source Code on Github](https://github.com/apexfarm/ApexTriggerHandler)
