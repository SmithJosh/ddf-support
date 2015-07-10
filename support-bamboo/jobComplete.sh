#!/bin/bash
# Check if job failed and, if so, update the GitHub PR status accordingly. Should be run at the end of every job.

if [ "${bamboo_inject_jobResult}" != "Success" ]; then
    curl -H "Authorization: token ${bamboo_github_api_password}" --request POST --data '{"state": "failure", "context": "bamboo", "description": "The Bamboo build could not complete due to an error!", "target_url": "https://codice-ddf.atlassian.net/builds/browse/${bamboo_planKey}-${bamboo_buildNumber}"}' https://api.github.com/repos/codice/ddf-libs/statuses/${bamboo_pull_sha}
fi