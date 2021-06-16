#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "Starts"
WIKI_USERNAME="$1"
WIKI_REPOSITORY_NAME="$2"
WIKI_REPOSITORY_BRANCH="$3"
USER_EMAIL="$4"
USER_NAME="$5"
COMMIT_MESSAGE="$6"
TARGET_BRANCH="$7"

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$WIKI_USERNAME/$WIKI_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

TARGET_DIR=$(mktemp -d)
# This mv has been the easier way to be able to remove files that were there
# but not anymore. Otherwise we had to remove the files from "$CLONE_DIR",
# including "." and with the exception of ".git/"
mv "$CLONE_DIR/.git*" "$TARGET_DIR"

echo "Copy contents to target git repository"
cp -ra "$SOURCE_DIRECTORY"/. "$TARGET_DIR"
cd "$TARGET_DIR"

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

ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
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
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$GITHUB_REPOSITORY.git" --set-upstream "$TARGET_BRANCH"
