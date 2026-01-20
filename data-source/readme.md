Use the following command to load the data with namespace:

> sfdx data:import:tree -o [org-alias] -p data-source/data-import-plan.json

In order to load data into org with namespace, add the namespace from field names and object names in the following files:

-   rules.json
-   rulesets.json
-   rules-in-set-capacity-based.json
-   rules-in-set-outcome-based.json
-   rules-in-set-msa.json
-   data-import-plan.json
