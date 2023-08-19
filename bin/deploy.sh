#!/bin/sh

GIT_SHA=$(git rev-parse --short HEAD)
ENV=$1

if [ -z $ENV ]; then
  echo "Missing argument ENV, example: bin/deploy.sh prod"
  exit 1
fi

if [ "dev" != $ENV -a "staging" != $ENV -a "prod" != $ENV ]; then
  echo "Only \"dev\", and \"prod\" are accepted deploy targets, got \"${ENV}\""
  exit 1
fi

git show HEAD

echo
echo

read -p "Release at this commit  [y/N]" YES_NO
YES_NO=$(echo $YES_NO | tr '[:upper:]' '[:lower:]')

if [ "$YES_NO" != "y" ]; then
  echo
  echo "Canceling release!"
  exit 1
fi

git tag ${ENV}-${GIT_SHA}
echo
echo
echo "Tagged the release as ${ENV}-${GIT_SHA}."
echo

git push origin main --tags

echo
echo "Pushed to github to trigger CD."
