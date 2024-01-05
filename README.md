# DMD (Document Mess Detector)

Native Salesforce app that uses Generative AI to check whether business documents in Files and Attachments comply with a set of rules.

[![](http://img.youtube.com/vi/kGpFUgR-6Bg/hqdefault.jpg)](https://youtu.be/kGpFUgR-6Bg "")

DMD lends its name from [PMD the famous and widely used Static Code Analyser](https://pmd.github.io/). While PMD improves the quality of code by checking its compliance against rulesets that define antipatterns and smells, DMD checks the quality of business documents like contracts, specifications and written agreements.

Understanding code for PMD is easy as code can understand code. Writing PMD rules was hard because humans had to learn how to write their rules in the language of the "machine".

DMD is very different and uses the latest breakthroughs in AI - Large Language Models (LLMs) like OpenAI's ChatGPT. LLMs with their capabilities to understand and reason natural language text are just perfect to rule description and prompts in natural language.

DMD is a technology proof-of-concept by the Salesforce Product Development Partner Aquiva Labs. It was built to showcase the use of Generative AI within a native Salesforce Managed Package, even before Salesforce releases its native, trusted LLM features.

The App is also available as a [free app on the AppExchange](https://appexchange.salesforce.com/appxListingDetail?listingId=8ae56cbd-8b6b-4009-bf17-1781d9416fe8) and as Open Source repository on Github.

### Highlight

- Write Rules in simple Natural language and group them in Rulesets.
- Run Analysis on Salesforce Files or Attachments
- Analysis Results will be justified by document quotes.
- Monitor the Accuracy of the AI using scheduled Regression Tests.
- Native Salesforce App with Custom Objects for Rules, Rulesets, Analyses etc.
- Uses Freemium Extractor API to extract text from documents (use your own API key)
- Uses Open AI API for text reasoning (use your own API key)
- Export & Import of Rulesets
- Comfortable Setup UI for Post-Install Steps
- Uses Custom Metadata Types to use other LLMs (was tested with Claude and Open Source Llama2)

### How do I use it?

Clone the repo, test it in a Scratch org using `scripts/create-scratch-org.sh` and then create your own Unlocked or Managed Package from it. All the steps, to configure and use the app can be found in the [User Guide (PDF)](user-guide.pdf).

### How do I extend it?

1. Clone the repo
1. Spin up a scratch org using `scripts/create-scratch-org.sh`
1. Understand the [Solution design](solution-design.md) to understand the architecture and components of the app
1. Adjust and Extend the app as you like