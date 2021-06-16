#!/bin/bash

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable
shopt -s extglob

echo "Starts"
WIKI_REPOSITORY="$1"
WIKI_BRANCH="$2"
USER_EMAIL="$3"
USER_NAME="$4"
COMMIT_MESSAGE="$5"
TARGET_REPOSITORY="$6"
TARGET_BRANCH="$7"

CLONE_DIR=$(mktemp -d)
echo "Cloning source wiki git repository into $CLONE_DIR"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"
git clone --single-branch --branch "$WIKI_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$WIKI_REPOSITORY.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

if [[ -z "$TARGET_REPOSITORY" ]];then
  TARGET_REPOSITORY="$GITHUB_REPOSITORY"
fi

TARGET_DIR=$(mktemp -d)
echo "Cloning current destination git repository into $TARGET_DIR"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_REPOSITORY.git" "$TARGET_DIR"

cd "$TARGET_DIR"
echo "Initial contents:"
ls -la
echo "Removing everything besides git files"
# remove everything that's not git/github related
rm -rv !(.git*)
echo "Retained files:"
ls -la

echo "Copy contents to target git repository"
cp -ra "$CLONE_DIR"/* .

if [[ -e Home.md ]];then
  echo "Moving Home.md to index.md"
  mv Home.md index.md
fi

echo "Writing new Home.md"
echo "---" > Home.md
echo "permalink: /Home" >> Home.md
echo "redirect_to:" >> Home.md
echo "  - /" >> Home.md
echo "---" >> Home.md

echo "Files that will be pushed:"
ls -la

ORIGIN_COMMIT="https://github.com/$TARGET_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

echo "git add:"
git add .

echo "git status:"
git status

echo "git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "git push origin:"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$TARGET_REPOSITORY.git" --set-upstream "$TARGET_BRANCH"
