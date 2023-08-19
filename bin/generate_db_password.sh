#!/bin/sh
set -e

DATABASE_HOST=$1
USERNAME=$2
REGION="us-west-2"
if [ -z $DATABASE_HOST ]; then
  echo "Choose the database to connect to. eg: \"db.prod.whatever.com\""
  exit 1
fi
if [ -z $USERNAME ]; then
  echo "Choose the user to connect with: \"whatever?\""
  exit 1
fi
RDSPASSWORD="$(aws rds generate-db-auth-token --hostname=$DATABASE_HOST --port=5432 --username=$USERNAME --region $REGION)"

echo $RDSPASSWORD
