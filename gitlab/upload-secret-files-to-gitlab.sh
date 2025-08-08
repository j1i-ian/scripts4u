#!/bin/bash

# This script is depends on jq command so You must install that.

GITLAB_URL=${1-"https://gitlab.com"} # Or Your Gitlab Server URL
GITLAB_PROJECT_ID=<YOUR GITLAB PROJECT ID>;

echo -n "Input your personal gitlab access token ( Visit $GITLAB_URL/-/profile/personal_access_tokens ) :"

GITLAB_ACCESS_TOKEN=$(cat .gitlab-token.txt 2>/dev/null);

if [[ -z "$GITLAB_ACCESS_TOKEN" ]]; then
    read GITLAB_ACCESS_TOKEN;
fi

if [[ -z "$GITLAB_ACCESS_TOKEN" ]]; then
    echo "Please input tokne correctly.";
    exit 1;
else

    SECRET_FILES=(
        "SECRET_FILE_1_LIKE_DOT_ENV"
        "SECRET_FILE_2_LIKE_DOT_ENV_LOCAL_DEV"
    )

    for SECRET_FILE in "${SECRET_FILES[@]}"; do
        SECRET_FILE_PATH="$SECRET_FILE"

        if [ ! -f "$SECRET_FILE_PATH" ]; then
            echo "Error: No file to upload: $SECRET_FILE_PATH"
            exit 1
        fi

        # 기존 파일 ID 찾기
        ALL_FILES_INFO=$(
            curl --silent --request GET \
                --header "PRIVATE-TOKEN: ${GITLAB_ACCESS_TOKEN}" \
                "${GITLAB_URL}/api/v4/projects/${GITLAB_PROJECT_ID}/secure_files"
        )
        echo "Existing file ID finding..."
        FILE_INFO=$(echo "${ALL_FILES_INFO}" | jq '.[] | select(.name == "'$SECRET_FILE'")')


        FILE_ID=$(echo "${FILE_INFO}" | jq -r '.id')

        if [ "${FILE_ID}" != "null" ]; then
            echo "Existing file '${SECRET_FILE}' (ID: ${FILE_ID})을 찾았습니다. 삭제합니다..."
            DELETE_RESPONSE=$(
                curl --request DELETE \
                    --header "PRIVATE-TOKEN: ${GITLAB_ACCESS_TOKEN}" \
                    "${GITLAB_URL}/api/v4/projects/${GITLAB_PROJECT_ID}/secure_files/${FILE_ID}"
            )
            echo "Delete Response: ${DELETE_RESPONSE}"
            echo "Removed previous secret file."
        else
            echo "No previous file:'${SECRET_FILE}'. New File would be uploaded"
        fi

        # upload with Gitlab API
        response=$(
            curl --request POST \
                --header "PRIVATE-TOKEN: ${GITLAB_ACCESS_TOKEN}" \
                --form "name=${SECRET_FILE}" \
                --form "file=@${SECRET_FILE_PATH}" \
                "${GITLAB_URL}/api/v4/projects/${GITLAB_PROJECT_ID}/secure_files"
        )

        # Gitlab API Response
        echo "API Response:"
        echo "$response" | jq .

        # Check file id and name
        file_id=$(echo "$response" | jq -r '.id')
        uploaded_file_name=$(echo "$response" | jq -r '.name')

        if [ -n "$file_id" ] && [ "$file_id" != "null" ]; then
            echo "Successfully uploaded Secure File:"
            echo "  Name: $uploaded_file_name"
            echo "  ID: $file_id"
        else
            echo "Failed to upload Secure File."
            echo "Please check your GITLAB_PROJECT_ID, GITLAB_ACCESS_TOKEN, and file path."
        fi

        echo "Uploading secure file '$SECRET_FILE_PATH' to project ID '$GITLAB_PROJECT_ID'..."
        echo "$SECRET_FILE_PATH has been uploaded..."
    done

fi

echo $GITLAB_ACCESS_TOKEN > .gitlab-token.txt
