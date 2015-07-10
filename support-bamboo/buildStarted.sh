#!/bin/bash
# Update the GitHub PR status to in-progress. Should be run at the start of the plan after ddf-support has been checked out.

curl -H "Authorization: token ${bamboo_github_api_password}" --request POST --data '{"state": "pending", "context": "bamboo", "description": "The Bamboo build is in progress", "target_url": "https://codice-ddf.atlassian.net/builds/browse/${bamboo_planKey}-${bamboo_buildNumber}"}' https://api.github.com/repos/codice/ddf-libs/statuses/${bamboo_pull_sha}