#!/bin/bash
# Push a tag for our repository if upstream PrusaSlicer generates a new release
# This was forked from https://github.com/dmagyar/prusaslicer-vnc-docker/blob/main/tagLatestPrusaSlicer.sh

set -eu

# ** start of configurable variables **

# GH_ACTION -- indicates that we are running in a github action, and instead of pushing, just use
# return codes to indicate whether or not continuing with the workflow is appropriate
GH_ACTION="y"

# LATEST_RELEASE -- where to find the latest PrusaSlicer release
LATEST_RELEASE="https://api.github.com/repos/prusa3d/PrusaSlicer/releases/latest"

# ** end of configurable variables **

# Get the latest tagged version
LATEST_VERSION="$(curl -SsL ${LATEST_RELEASE} | jq -r '.tag_name | select(test("^version_[0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{1,2}\\-{0,1}(\\w+){0,1}$"))' | cut -d_ -f2)"

if [[ -z "${LATEST_VERSION}" ]]; then

  echo "Could not determine the latest version."
  echo "Has release naming changed from previous conventions?"
  echo "${LATEST_VERSION}"
  exit 1

fi


# Run from the git repository
cd "$(dirname "$0")";

# Get the latest tag (by tag date, not commit) in our repository
LATEST_GIT_TAG=$(git for-each-ref refs/tags --sort=-creatordate --format='%(refname:short)' --count=1)

if [[ "${LATEST_GIT_TAG}" != "${LATEST_VERSION}" ]]; then

  echo "Update needed. Latest tag ver: ${LATEST_GIT_TAG} != upstream ver: ${LATEST_VERSION} .."
  git tag "${LATEST_VERSION}"

  if [[ "$GH_ACTION" != "" ]]; then
    echo "${LATEST_VERSION}" > ${GITHUB_WORKSPACE}/VERSION
    git push https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY --tags
    exit 0
  else
    git push --tags
  fi    

else

  echo "Latest tag ver: ${LATEST_GIT_TAG} == upstream ver: ${LATEST_VERSION} -- no update"
  exit 0

fi