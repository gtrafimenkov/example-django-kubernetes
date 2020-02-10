#!/bin/bash

set -e

POSTGRES_HELM_NAME=cph-test-db

SD=$(dirname $0)

# helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install \
    $POSTGRES_HELM_NAME \
    --set image.repository=postgres \
    --set image.tag=10.6 \
    --set postgresqlDataDir=/data/pgdata \
    --set persistence.mountPath=/data/ \
    stable/postgresql
