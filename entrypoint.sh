#!/bin/bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_PATH"
    local def="${2:-}"

    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi

    local val="$def"

    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi

    export "$var"="$val"
    unset "$fileVar"
}

file_env 'GOOGLE_CREDENTIALS' ''
file_env 'AZUREBLOB_KEY' ''

echo "Create rclone.conf file."

cat <<EOF > /etc/rclone.conf
[s3]
    type = s3
    env_auth = false
    provider = ${S3_PROVIDER:-"AWS"}
    access_key_id = ${S3_ACCESS_KEY_ID}
    secret_access_key = ${S3_SECRET_KEY}
    region = ${S3_REGION:-"us-east-1"}
    endpoint = ${S3_ENDPOINT}
    acl = ${S3_ACL}
    storage_class = ${S3_STORAGE_CLASS}

[gs]
    type = google cloud storage
    project_number = ${GOOGLE_PROJECT_ID}
    service_account_file = /tmp/google-credentials.json
    object_acl = ${GOOGLE_OBJECT_ACL}
    bucket_acl = ${GOOGLE_BUCKET_ACL}
    location =  ${GOOGLE_LOCATION}
    storage_class = ${GOOGLE_STORAGE_CLASS:-"MULTI_REGIONAL"}

[http]
    type = http
    url = ${HTTP_URL}

[azure]
    type = azure blob storage
    account = ${AZUREBLOB_ACCOUNT}
    key = ${AZUREBLOB_KEY}
EOF

echo "Create google-credentials.json file."
cat <<EOF > /tmp/google-credentials.json
${GOOGLE_CREDENTIALS}
EOF

exec rclone "$@"
