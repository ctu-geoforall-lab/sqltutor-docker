#!/bin/bash -e

function install_tutorial() {
    LANG=$1
    DATASET=$2

    psql -h db -U postgres ${SQLTUTOR_DATABASE} < ./extra_datasets/${LANG}/${DATASET}/${DATASET}_data.sql
    psql -h db -U postgres ${SQLTUTOR_DATABASE} < ./extra_datasets/${LANG}/${DATASET}/${DATASET}_dataset.sql
    psql -h db -U postgres ${SQLTUTOR_DATABASE} < ./extra_datasets/${LANG}/${DATASET}/${DATASET}.sql
    psql -h db -U postgres ${SQLTUTOR_DATABASE} < ./extra_datasets/${LANG}.${DATASET}.sql
}

install_tutorial cs uzpr
