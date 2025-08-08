#!/bin/bash

DB_PRODUCT=${1:-"mariadb"}
DB_HOST=
DB_NAME=
DB_USER=
DB_PASSWORD=

ENTITY_PATH=${2:-src/entities}

npx typeorm-model-generator -h $DB_HOST -d $DB_NAME --namingStrateg=SnakeNamingStrategy -u $DB_USER -x $DB_PASSWORD -e $DB_PRODUCT -o $ENTITY_PATH

. ./scripts/modelgen-postprocess.sh
