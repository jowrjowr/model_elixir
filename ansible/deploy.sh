#!/bin/sh

env=$1

git_sha=$(git rev-parse --verify HEAD)

if [ -z "$env" ]; then
  echo "Missing argument ENV, example: ansible/deploy.sh dev"
  exit 1
fi

ansible-galaxy collection install amazon.aws

# the reason nix-shell is invoked this way is because ansible won't know where the
# boto3/botocore python modules are otherwise. this results in the aws_ec2 plugin whining.

deployment_playbook="${env}.aws_ec2.yml deployment-playbook.yml"

nix-shell -p python39Packages.boto3 python39Packages.botocore --run "ansible-playbook -i $deployment_playbook -e git_sha=$git_sha"

exit_code=$?

if [ "$exit_code" -gt 0 ]; then
  exit 1
fi

