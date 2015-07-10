#!/bin/bash
# Update the GitHub PR status to success. Should be run in its own stage at the end of the plan.

curl -H "Authorization: token ${bamboo_github_api_password}" --request POST --data '{"state": "success", "context": "bamboo", "description": "The Bamboo build passed", "target_url": "https://codice-ddf.atlassian.net/builds/browse/${bamboo_planKey}-${bamboo_buildNumber}"}' https://api.github.com/repos/codice/ddf-libs/statuses/${bamboo_pull_sha}