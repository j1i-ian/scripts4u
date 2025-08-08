#!/bin/bash

GITLAB_URL=${1-"https://gitlab.com"} # Or Your Gitlab Server URL
GITLAB_PROJECT_ID=<YOUR GITLAB PROJECT ID>;

echo -n "Input your personal gitlab access token (Visit $GITLAB_URL/-/profile/personal_access_tokens): "

read GITLAB_ACCESS_TOKEN;

if [[ -z "$GITLAB_ACCESS_TOKEN" ]]; then
    echo "Please input access token correctly.";
    exit 1;
else

    # Secret file list
    curl -H "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" --silent "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/secure_files" | \
    jq -c '.[]' | \
    jq -c '[.id, .name] | @sh' | \
    tr -d \' | \
    tr -d \" | \
    while read object;
    do
        SECRET_FILE_ID=$(echo "${object[0]}" | cut -d ' ' -f1);
        SECRET_FILE_NAME=$(echo "${object[0]}" | cut -d ' ' -f2);

        curl -H "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
            "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/secure_files/$SECRET_FILE_ID/download" \
            > "./$SECRET_FILE_NAME" ;
    done
fi