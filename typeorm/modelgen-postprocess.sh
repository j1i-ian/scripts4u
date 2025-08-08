#!/bin/bash

ENTITY_PATH=src/entities

# Fix generated model
FILES=$(find $ENTITY_PATH -name "*.ts" -type f)
for FILE in $FILES
do
    echo $FILE
    # Fix default empty string
    sed -i '' -e "s/() => \"''\"/''/g" "$FILE" 1>/dev/null 2>/dev/null

    # Fix default int 0
    sed -i '' -e "s/() => \"'0'\"/0/g" "$FILE" 1>/dev/null 2>/dev/null
    sed -i '' -e "s/() => \"'1'\"/1/g" "$FILE" 1>/dev/null 2>/dev/null

    # Fix default ENUM_VALUE enum string
    sed -i '' -e "s/() => \"'ENUM_VALUE'\"/\"ENUM_VALUE\"/g" "$FILE" 1>/dev/null 2>/dev/null
done
