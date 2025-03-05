#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/getDataFile.sh
source getDynamicVars.sh

TASK_STATUS=0

# Set environment variable for the date
export BUILD_DATE=$(date +%Y-%m-%d)

# Example: Using while loop inside a command
echo "Processing on date: $BUILD_DATE"

REPO_NAME=$CODEBASE_DIR
BRANCH_NAME=`getGitBranch`

# Main logic to check conditions and call fetch_service_details
if [ -n "$SOURCE_VARIABLE_REPO" ]; then
    # Check if MINIO_ACCESS_KEY and MINIO_SECRET_KEY are provided
    if [ -n "$MINIO_ACCESS_KEY" ] && [ -n "$MINIO_SECRET_KEY" ]; then
        echo "MINIO_ACCESS_KEY and MINIO_SECRET_KEY are provided. Skipping fetching details from SOURCE_VARIABLE_REPO."
    else
        echo "Fetching details from $SOURCE_VARIABLE_REPO as MINIO_ACCESS_KEY and MINIO_SECRET_KEY are not provided."
        fetch_service_details
    fi
else
    logErrorMessage "SOURCE_VARIABLE_REPO is not defined. Skipping fetching details from $SOURCE_VARIABLE_REPO."
fi

# Check if MINIO_SOURCE_PATH exists
if [ -z "$MINIO_SOURCE_PATH" ]; then
    logErrorMessage "❌ MINIO_SOURCE_PATH is not defined. Skipping tar.gz archive creation."
    exit 1
fi

if [ ! -e "$MINIO_SOURCE_PATH" ]; then
    logErrorMessage "❌ MINIO_SOURCE_PATH does not exist: $MINIO_SOURCE_PATH"
    exit 1
fi

# Determine tarball name
MINIO_SOURCE_PATH_TAR_FILE="${MINIO_SOURCE_PATH%/}-$(date +%Y%m%d%H%M%S).tar.gz"

# Handle if MINIO_SOURCE_PATH is a directory or a file
if [ -d "$MINIO_SOURCE_PATH" ]; then
    echo "📁 MINIO_SOURCE_PATH is a directory. Creating archive: $MINIO_SOURCE_PATH_TAR_FILE"
    tar -czf "$MINIO_SOURCE_PATH_TAR_FILE" -C "$(dirname "$MINIO_SOURCE_PATH")" "$(basename "$MINIO_SOURCE_PATH")"
elif [ -f "$MINIO_SOURCE_PATH" ]; then
    echo "📄 MINIO_SOURCE_PATH is a file. Creating archive: $MINIO_SOURCE_PATH_TAR_FILE"
    tar -czf "$MINIO_SOURCE_PATH_TAR_FILE" -C "$(dirname "$MINIO_SOURCE_PATH")" "$(basename "$MINIO_SOURCE_PATH")"
else
    logErrorMessage "❌ MINIO_SOURCE_PATH is not a valid file or directory: $MINIO_SOURCE_PATH"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "✅ Archive successfully created: $MINIO_SOURCE_PATH_TAR_FILE 🎉"
    export MINIO_SOURCE_PATH="${MINIO_SOURCE_PATH_TAR_FILE}"
    export MINIO_SOURCE_FILE_NAME="$(basename "$MINIO_SOURCE_PATH_TAR_FILE")"
    export MINIO_DEST_PATH="$MINIO_DEST_PATH/$APPLICATION_NAME/$REPO_NAME/$BRANCH_NAME/$BUILD_DATE/$BUILD_NUMBER/$MINIO_SOURCE_FILE_NAME"
else
    logErrorMessage "❌ Failed to create tar.gz archive of $MINIO_SOURCE_PATH"
    exit 1
fi

# Trigger `minio_upload.py` if required
if [ "$TASK_STATUS" -eq 0 ]; then
    logInfoMessage "Triggering minio_upload.py..."
    python3 minio_upload.py || { logErrorMessage "Failed to execute minio_upload.py"; exit 1; }
else
    logErrorMessage "Skipping minio_upload.py due to task failure."
fi

TASK_STATUS=$?

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}