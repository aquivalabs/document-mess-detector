#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}


echo "set default devhub user"
execute sf config set defaultdevhubusername=$DEV_HUB_ALIAS

echo "Deleting old scratch org"
sf org delete scratch --no-prompt --target-org $SCRATCH_ORG_ALIAS

echo "Creating scratch org"
execute sf org create scratch --alias $SCRATCH_ORG_ALIAS --set-default --definition-file ./config/project-scratch-def.json --duration-days 30

echo "Make sure Org user is english"
sf data update record --sobject User --where "Name='User User'" --values "Languagelocalekey=en_US"

echo "Pushing changes to scratch org"
execute sf project deploy start

echo "Assigning permissions"
execute sf org assign permset --name AppAdministrator --name DocumentReviewer --name RuleAuthor --name EinsteinGPTPromptTemplateManager

echo "Running Apex Tests"
execute sf apex run test --test-level RunLocalTests --code-coverage --result-format human --synchronous