# Detect Apex issues with PMD

[Overview](#overview) | [Usage](#usage) | [Handle Issues](#handle-issues) | [Customize Rules](#customize-rules)

---
## Overview

[PMD is the most versatile and accepted tool](https://pmd.github.io/) to detect issues in code. It is Open Source with a HUGE community that contributes new and improves existing rules, but its also fully supported by Salesforce. Salesforce contributed many of the Security rules and leverages PMD as the core engine of its [Salesforce Code Scanner](https://forcedotcom.github.io/sfdx-scanner/).

PMD as a Single-File Static Scanner is not the optimal tool to detect Security issues. This is why there are so many commercial player (Checkmarx, CodeScan, Clayton, DigitSec) around and why Salesforce is investing in its Graph Engine which is an integral and OSS part of its [Code Scanner](https://forcedotcom.github.io/sfdx-scanner/).

Another good thing is that with [Robert Sösemann we have the "guy who built Apex PMD in 2016"](https://www.youtube.com/watch?v=bW7m6y6bEug) and consulted Salesforce in building thr Salesforce Code Scanner within Aquiva.

If you want to learn check those links:

- [Boost Code Performance with Salesforce Code Analyzer](https://developer.salesforce.com/blogs/2023/02/boost-code-performance-with-salesforce-code-analyzer)
- [Play by Play: Automated Code Analysis in Salesforce - a Tools Deep-Dive](https://app.pluralsight.com/course-player?clipId=298d2f3d-15bc-47c4-8e88-ef2e4a2a95c3)

Aquiva is using all of that tools and this folder contains a ruleset to [adjust PMD standard rules](pmd/ruleset.xml):

```xml
<rule ref="category/apex/security.xml">
    <priority>1</priority>                                  
</rule>
<rule ref="category/apex/design.xml" />
<rule ref="category/apex/bestpractices.xml">
    <exclude name="ApexUnitTestClassShouldHaveRunAs" />
    <exclude name="AvoidStaticDmlStatementsOutsideOfTests" />
    <exclude name="ApexAssertionsShouldIncludeMessage" />
</rule>
```


and add additional Custom Aquiva-specific XPath rules for [Apex](pmd/category/apex/custom.xml):

```xml
<rule name="AvoidProductionDebugLogs" language="apex" message="Avoid leaving System.debug() statments in code as they negativly influence performance." class="net.sourceforge.pmd.lang.apex.rule.ApexXPathRule">
    <properties>
        <property name="xpath">
            <value><![CDATA[
            //MethodCallExpression[lower-case(@FullMethodName)='system.debug'][count(*)=2]
            ]]></value>
        </property>
    </properties>
</rule>
```

and [XML metadata](pmd/category/xml/custom.xml):

```xml
<rule name="MetadataRequiresDescription" language="xml" message="Add a description to explain custom metadata" class="net.sourceforge.pmd.lang.rule.XPathRule">
    <priority>2</priority>
    <properties>
        <property name="version" value="2.0"></property>
        <property name="xpath">
            <value><![CDATA[
                //*[self::CustomObject or self::CustomField][not(description)]
            ]]></value>
        </property>
    </properties>
</rule>
```

## Usage

## Handle issues

If PMD finds and issue, fix it. Don't alibi fix it but really make it better, more clean or more secure. If you don't know how to do it, learn, do some research or reach out in Slack with #salesforce or #quality-code.

If it's a False Positive flag it directly in code with a proper explanation like this:

- Rule-specific `@SuppressWarnings`
- Comment with the words `PMD False Positive` and a concise explanation

```java
// PMD False Positive: Accessed from outside
//                     Managed Package
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class LegacyClass {

  ...
}
```

## Customize rules

To detect more issues and have less False Positives feel free to adjust the ruleset, adjust and add more custom rules.

If you find your adjustments to stand the test of time and are applicable for other please share them in Slack with #salesforce or #quality-code.

Never use this to trick yourself and make issues go away. 
