#!/bin/bash
# Checkout code from the PR branch

if [[ -n ${bamboo_pull_num} ]]; then
  echo "== git fetch PR ${bamboo_pull_num} from ${bamboo_repository_git_repositoryUrl} =="
  mkdir ${bamboo_repo_name}
  cd ${bamboo_repo_name}
  git init
  git remote add origin ${bamboo_repository_git_repositoryUrl}
  git fetch --depth 1 origin +refs/pull/${bamboo_pull_num}/head
  git checkout FETCH_HEAD
fi