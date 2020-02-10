#!/bin/bash

set -e

POSTGRES_HELM_NAME=cph-test-db

SD=$(dirname $0)

export POSTGRES_PASSWORD=$(kubectl get secret \
    --namespace default $POSTGRES_HELM_NAME-postgresql \
    -o jsonpath="{.data.postgresql-password}" | base64 --decode)

cat $SD/create-app-db-and-user.sql | kubectl run $POSTGRES_HELM_NAME-postgresql-client \
    --rm -i --restart='Never' --namespace default \
    --image docker.io/bitnami/postgresql:11.6.0-debian-10-r5 \
    --env="PGPASSWORD=$POSTGRES_PASSWORD" \
    --command -- psql --host $POSTGRES_HELM_NAME-postgresql -U postgres -d postgres -p 5432 -f -
