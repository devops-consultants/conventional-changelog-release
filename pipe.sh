#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"


# Required parameters
TF_MODULE_PATH=${TF_MODULE_PATH:?"TF_MODULE_PATH env variable is required"}

# Default values
DEBUG=${DEBUG:="false"}
TAG_PREFIX=${TAG_PREFIX:="v"}

COMMITTER_NAME=${GIT_COMMITTER_NAME:="Conventional Commits Release"}
COMMITTER_EMAIL=${GIT_COMMITTER_EMAIL:="noreply@example.com"}

# RUN_TFLINT=${RUN_TFLINT:="true"}
# RUN_TRIVY=${RUN_TRIVY:="true"}
# RUN_VALIDATE=${RUN_VALIDATE:="true"}
# RUN_FMT=${RUN_FMT:="true"}

enable_debug() {
  if [[ "${DEBUG}" == "true" ]]; then
    info "Enabling debug mode."
    set -x
  fi
}
enable_debug

increment_version() {
    local version=$1
    local increment=$2
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    local patch=$(echo $version | cut -d. -f3)

    if [ "$increment" == "major" ]; then
        major=$((major + 1))
        minor=0
        patch=0
    elif [ "$increment" == "minor" ]; then
        minor=$((minor + 1))
        patch=0
    elif [ "$increment" == "patch" ]; then
        patch=$((patch + 1))
    fi

    echo "${major}.${minor}.${patch}"
}


info "Running module release for ${TF_MODULE_PATH}"

LAST_TAG=$(git-semver-tags --tag-prefix "${TAG_PREFIX}" | head -n 1)
GIT_FILTER="${LAST_TAG}..HEAD"
if [[ -z "${LAST_TAG}" ]]; then
  info "No tags found - new release starting at 0.0.0"
  LAST_VERSION="0.0.0"
  GIT_FILTER=""
else
  info "Last release: ${LAST_TAG}"
  LAST_VERSION=$(echo "${LAST_TAG}" | sed "s/${TAG_PREFIX}//")
fi


NUM_COMMITS=$(git log --oneline ${GIT_FILTER} -- ${TF_MODULE_PATH} | wc -l)
info "Number of commits since last release: ${NUM_COMMITS}"

if [[ "${NUM_COMMITS}" == "0" ]]; then
  success "No changes detected, skipping release"
  exit 0
fi

INCREMENT_TYPE=$(conventional-recommended-bump -p conventionalcommits --commit-path ${TF_MODULE_PATH})
echo -n "Version Increment: "
conventional-recommended-bump -p conventionalcommits --commit-path ${TF_MODULE_PATH} -v

NEW_VERSION=$(increment_version ${LAST_VERSION} ${INCREMENT_TYPE})
info "New version: ${NEW_VERSION}"

# git tag -a "${TAG_PREFIX}${NEW_VERSION}" -m "Release ${TAG_PREFIX}${NEW_VERSION}"
git tag "${TAG_PREFIX}${NEW_VERSION}" 

info "Generating CHANGELOG.md"
run conventional-changelog -p conventionalcommits -i ${TF_MODULE_PATH}/CHANGELOG.md -s -r 0 -t ${TAG_PREFIX} --commit-path ${TF_MODULE_PATH} -u false
if [[ "${status}" == "0" ]]; then
  success "Success!"
else
  fail "Error!"
fi

GIT_AUTHOR_NAME=${COMMITTER_NAME}
GIT_AUTHOR_EMAIL=${COMMITTER_EMAIL}
GIT_COMMITTER_NAME=${COMMITTER_NAME}
GIT_COMMITTER_EMAIL=${COMMITTER_EMAIL}
EMAIL=${COMMITTER_EMAIL}
export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL EMAIL

git add ${TF_MODULE_PATH}/CHANGELOG.md
git commit -m "chore(release): update changelog for ${TF_MODULE_PATH} [skip ci]"
git tag -f -am "Tagging for release ${TAG_PREFIX}${NEW_VERSION}" "${TAG_PREFIX}${NEW_VERSION}" 
git push origin "${TAG_PREFIX}${NEW_VERSION}"

# cd ${TF_MODULE_PATH}

# if [[ "${RUN_FMT}" == "true" ]]; then
#   info "Checking module formatting"
#   run terraform init && terraform fmt -check

#   if [[ "${status}" == "0" ]]; then
#     success "Success!"
#   else
#     fail "Error!"
#   fi
# fi

# if [[ "${RUN_VALIDATE}" == "true" ]]; then
#   info "Checking module validation"
#   run terraform validate

#   if [[ "${status}" == "0" ]]; then
#     success "Success!"
#   else
#     fail "Error!"
#   fi
# fi


# if [[ "${RUN_TFLINT}" == "true" ]]; then
#   info "Checking module linting"
#   run tflint

#   if [[ "${status}" == "0" ]]; then
#     success "Success!"
#   else
#     fail "Error!"
#   fi
# fi

# if [[ "${RUN_TRIVY}" == "true" ]]; then
#   info "Checking module vulnerabilities"
#   run trivy config .

#   if [[ "${status}" == "0" ]]; then
#     success "Success!"
#   else
#     fail "Error!"
#   fi
# fi